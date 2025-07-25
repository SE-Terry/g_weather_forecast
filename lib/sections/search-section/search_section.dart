import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/weather_provider.dart';
import '../../services/weather_api_service.dart';
import 'dart:async';
import '../../services/email_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html show window;
import 'dart:js' as js;

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final TextEditingController _controller = TextEditingController();
  final WeatherApiService _apiService = WeatherApiService();
  final FocusNode _focusNode = FocusNode();
  bool _isGettingLocation = false;
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) {
          _hideSuggestions();
        }
      });
    }
  }

  void _onSearchChanged() {
    final query = _controller.text.trim();

    if (query.isEmpty) {
      _hideSuggestions();
      return;
    }

    if (query.length < 3) {
      _hideSuggestions();
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchCities(query);
    });
  }

  Future<void> _searchCities(String query) async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final suggestions = await _apiService.searchCities(query);

      if (mounted) {
        setState(() {
          _suggestions = suggestions.take(5).toList();
          _showSuggestions = _suggestions.isNotEmpty;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
          _isSearching = false;
        });
      }
    }
  }

  void _selectSuggestion(String selectedCity) {
    _debounceTimer?.cancel();
    _hideSuggestions();
    _focusNode.unfocus();
    _controller.removeListener(_onSearchChanged);
    _controller.text = selectedCity;

    scheduleMicrotask(() {
      _controller.addListener(_onSearchChanged);
    });
  }

  void _hideSuggestions() {
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
  }

  void _searchWeather() {
    final city = _controller.text.trim();
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a city name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _hideSuggestions();
    final weatherProvider = Provider.of<WeatherProvider>(
      context,
      listen: false,
    );
    weatherProvider.fetchWeather(city);
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // For web, try a more direct approach first
      if (kIsWeb) {
        try {
          final position = await _getLocationWeb();
          if (position != null) {
            if (!mounted) return;
            final weatherProvider = Provider.of<WeatherProvider>(
              context,
              listen: false,
            );
            await weatherProvider.fetchWeather(
              '${position['latitude']},${position['longitude']}',
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Weather updated for your current location'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            return;
          }
        } catch (webError) {
          // If web geolocation fails with a clear error, don't fall back
          String errorStr = webError.toString().toLowerCase();
          if (errorStr.contains('denied') || errorStr.contains('permission')) {
            throw Exception(
              'Location permission denied. Please allow location access in your browser and try again.',
            );
          }
          // For other web errors, we can try fallback
          print('Web geolocation failed: $webError');
        }
      }

      // Fallback to original geolocator approach only for non-web or non-permission errors
      if (!kIsWeb) {
        await _getCurrentLocationGeolocator();
      } else {
        // For web, if JavaScript method failed for reasons other than permission, show error
        throw Exception(
          'Unable to access location. Please ensure location services are enabled and permissions are granted.',
        );
      }
    } catch (e) {
      if (mounted) {
        _handleLocationError(e);
      }
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<Map<String, double>?> _getLocationWeb() async {
    if (!kIsWeb) return null;

    try {
      // Check if geolocation is available
      if (html.window.navigator.geolocation == null) {
        throw Exception('Geolocation not available');
      }

      final completer = Completer<Map<String, double>?>();

      // Use JavaScript directly
      try {
        js.context.callMethod('eval', [
          '''
          if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
              function(position) {
                window.flutterLocationSuccess = {
                  latitude: position.coords.latitude,
                  longitude: position.coords.longitude
                };
              },
              function(error) {
                console.log('Geolocation error:', error);
                window.flutterLocationError = error.message || error.code || 'Location error';
              },
              {
                enableHighAccuracy: true,
                timeout: 15000,
                maximumAge: 0
              }
            );
          } else {
            window.flutterLocationError = 'Geolocation not supported';
          }
        ''',
        ]);
      } catch (jsError) {
        throw Exception('JavaScript execution error: $jsError');
      }

      // Wait for result
      int attempts = 0;
      while (attempts < 30) {
        // 15 seconds timeout
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;

        // Check for success
        final success = js.context['flutterLocationSuccess'];
        if (success != null) {
          final result = {
            'latitude': success['latitude'] as double,
            'longitude': success['longitude'] as double,
          };
          // Clean up
          js.context['flutterLocationSuccess'] = null;
          js.context['flutterLocationError'] = null;
          return result;
        }

        // Check for error
        final error = js.context['flutterLocationError'];
        if (error != null) {
          final errorMsg = error.toString();
          // Clean up
          js.context['flutterLocationSuccess'] = null;
          js.context['flutterLocationError'] = null;

          // Handle specific error messages
          if (errorMsg.contains('denied') || errorMsg.contains('User denied')) {
            throw Exception(
              'Location permission denied. Please allow location access in your browser settings and try again.',
            );
          } else if (errorMsg.contains('unavailable')) {
            throw Exception(
              'Location is currently unavailable. Please check your device settings and try again.',
            );
          } else if (errorMsg.contains('timeout')) {
            throw Exception('Location request timed out. Please try again.');
          } else {
            throw Exception('Location error: $errorMsg');
          }
        }
      }

      throw Exception('Location request timed out');
    } catch (e) {
      print('Web geolocation error: $e');
      return null;
    }
  }

  Future<void> _getCurrentLocationGeolocator() async {
    // Check if running on web and if HTTPS is required
    if (kIsWeb && !_isSecureContext()) {
      throw Exception(
        'Geolocation requires HTTPS in production. Please access the app via HTTPS.',
      );
    }

    // Add a small delay to ensure the web context is ready
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    bool serviceEnabled;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      if (kIsWeb) {
        throw Exception(
          'Unable to check location services. Please ensure you\'re using a supported browser with HTTPS.',
        );
      }
      throw Exception(
        'Location services are disabled. Please enable location services in your browser.',
      );
    }

    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable location services in your browser.',
      );
    }

    LocationPermission permission;
    try {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(
            'Location permission denied. Please allow location access in your browser settings.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied. Please reset permissions in your browser settings.',
        );
      }
    } catch (e) {
      if (kIsWeb) {
        throw Exception(
          'Unable to request location permission. Please check your browser settings and ensure HTTPS is enabled.',
        );
      }
      rethrow;
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      if (kIsWeb) {
        // Handle specific web geolocation errors
        String errorStr = e.toString().toLowerCase();
        if (errorStr.contains('timeout')) {
          throw Exception('Location request timed out. Please try again.');
        } else if (errorStr.contains('permission') ||
            errorStr.contains('denied')) {
          throw Exception(
            'Location access denied. Please allow location access and try again.',
          );
        } else if (errorStr.contains('unavailable')) {
          throw Exception(
            'Location is currently unavailable. Please try again later.',
          );
        } else {
          throw Exception(
            'Unable to get your location. Please ensure location services are enabled and you\'re using HTTPS.',
          );
        }
      }
      rethrow;
    }

    if (!mounted) return;
    final weatherProvider = Provider.of<WeatherProvider>(
      context,
      listen: false,
    );
    await weatherProvider.fetchWeather(
      '${position.latitude},${position.longitude}',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weather updated for your current location'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleLocationError(dynamic e) {
    String errorMessage = 'Failed to get location';

    // More comprehensive error handling
    try {
      String errorString = e.toString();

      // Handle different types of errors
      if (errorString.contains('[object Object]')) {
        errorMessage =
            'Location access failed. Please ensure you\'re using HTTPS and have granted location permissions.';
      } else if (errorString.contains('NotAllowedError') ||
          errorString.contains('denied')) {
        errorMessage =
            'Location access denied. Please allow location access in your browser and try again.';
      } else if (errorString.contains('HTTPS')) {
        errorMessage =
            'Location access requires HTTPS. Please access the app via a secure connection.';
      } else if (errorString.contains('timeout') ||
          errorString.contains('TimeoutException')) {
        errorMessage = 'Location request timed out. Please try again.';
      } else if (errorString.contains('PositionUnavailableError')) {
        errorMessage =
            'Location unavailable. Please check your device settings and try again.';
      } else if (errorString.contains('LocationServiceDisabledException')) {
        errorMessage =
            'Location services are disabled. Please enable location services in your browser.';
      } else if (errorString.contains('PermissionDeniedException')) {
        errorMessage =
            'Location permission denied. Please allow location access and try again.';
      } else if (errorString.isNotEmpty &&
          !errorString.contains('Exception:')) {
        errorMessage = 'Location error: $errorString';
      } else {
        // For web-specific issues
        if (kIsWeb) {
          errorMessage =
              'Unable to access location. Please ensure:\n• You\'re using HTTPS\n• Location permissions are granted\n• Location services are enabled';
        } else {
          errorMessage = 'Failed to get location: $errorString';
        }
      }
    } catch (stringError) {
      // If even string conversion fails
      errorMessage =
          'Location access failed. Please check your browser settings and ensure the app is accessed via HTTPS.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Help',
          textColor: Colors.white,
          onPressed: () {
            _showLocationHelpDialog();
          },
        ),
      ),
    );
  }

  bool _isSecureContext() {
    if (!kIsWeb) return true;

    // In debug mode, localhost is considered secure
    if (Uri.base.host == 'localhost' ||
        Uri.base.host == '127.0.0.1' ||
        Uri.base.host.contains('localhost')) {
      return true;
    }

    // Check if the current context is HTTPS
    bool isHttps = Uri.base.scheme == 'https';

    // Debug logging for web context
    if (kIsWeb) {
      print('Debug - Current URL: ${Uri.base.toString()}');
      print('Debug - Scheme: ${Uri.base.scheme}');
      print('Debug - Host: ${Uri.base.host}');
      print('Debug - Is HTTPS: $isHttps');
    }

    return isHttps;
  }

  void _showEmailSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Subscribe for Daily Weather'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Get daily weather forecasts delivered to your email every morning!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                '• Current weather conditions\n'
                '• 4-day forecast\n'
                '• Weather alerts\n'
                '• Personalized for your location',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Email verification required. You can unsubscribe anytime.',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe Later'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6286E6),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _showEmailRegistrationForm();
              },
              child: const Text(
                'Subscribe',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEmailRegistrationForm() {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool isRegistering = false;
    bool isUnsubscribing = false;
    bool isSubmitted = false;
    String? confirmationMessage;
    final EmailService emailService = EmailService();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<String> _getUserLocation() async {
              try {
                // Check if user has searched for a city
                final weatherProvider = Provider.of<WeatherProvider>(
                  context,
                  listen: false,
                );
                if (weatherProvider.currentWeather != null) {
                  final locationData =
                      weatherProvider.currentWeather!['location'];
                  if (locationData != null) {
                    final name = locationData['name'] ?? '';
                    final region = locationData['region'] ?? '';
                    final country = locationData['country'] ?? '';

                    String location = name;
                    if (region.isNotEmpty && region != name) {
                      location += ', $region';
                    }
                    if (country.isNotEmpty) {
                      location += ', $country';
                    }
                    return location.isNotEmpty ? location : 'your location';
                  }
                }

                // For web, try the JavaScript-based location method first
                if (kIsWeb) {
                  try {
                    final position = await _getLocationWeb();
                    if (position != null) {
                      // Get location name from coordinates using weather API
                      try {
                        final weatherData = await _apiService.getCurrentWeather(
                          '${position['latitude']},${position['longitude']}',
                        );
                        if (weatherData != null) {
                          final locationData = weatherData['location'];
                          if (locationData != null) {
                            final name = locationData['name'] ?? '';
                            final region = locationData['region'] ?? '';
                            final country = locationData['country'] ?? '';

                            String location = name;
                            if (region.isNotEmpty && region != name) {
                              location += ', $region';
                            }
                            if (country.isNotEmpty) {
                              location += ', $country';
                            }
                            return location.isNotEmpty
                                ? location
                                : 'your location';
                          }
                        }
                      } catch (e) {
                        // If weather API fails, return coordinates as fallback
                        return '${position['latitude']!.toStringAsFixed(2)}, ${position['longitude']!.toStringAsFixed(2)}';
                      }
                    }
                  } catch (webError) {
                    // If location permission is denied, return generic location
                    print('Web geolocation failed for email: $webError');
                    return 'your location';
                  }
                }

                // Fallback to geolocator for non-web platforms
                if (!kIsWeb) {
                  // Check if running on web and if HTTPS is required
                  if (kIsWeb && !_isSecureContext()) {
                    return 'your location';
                  }

                  // Try to get current location
                  bool serviceEnabled =
                      await Geolocator.isLocationServiceEnabled();
                  if (!serviceEnabled) {
                    return 'your location';
                  }

                  LocationPermission permission =
                      await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) {
                      return 'your location';
                    }
                  }

                  if (permission == LocationPermission.deniedForever) {
                    return 'your location';
                  }

                  Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                    timeLimit: const Duration(seconds: 10),
                  );

                  // Get location name from coordinates using weather API
                  try {
                    final weatherData = await _apiService.getCurrentWeather(
                      '${position.latitude},${position.longitude}',
                    );
                    if (weatherData != null) {
                      final locationData = weatherData['location'];
                      if (locationData != null) {
                        final name = locationData['name'] ?? '';
                        final region = locationData['region'] ?? '';
                        final country = locationData['country'] ?? '';

                        String location = name;
                        if (region.isNotEmpty && region != name) {
                          location += ', $region';
                        }
                        if (country.isNotEmpty) {
                          location += ', $country';
                        }
                        return location.isNotEmpty ? location : 'your location';
                      }
                    }
                  } catch (e) {
                    // If weather API fails, return coordinates as fallback
                    return '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
                  }
                }

                return 'your location';
              } catch (e) {
                print('Error getting user location for email: $e');
                return 'your location';
              }
            }

            Future<void> handleRegister() async {
              if (!formKey.currentState!.validate()) return;
              setState(() => isRegistering = true);
              try {
                final location = await _getUserLocation();
                await emailService.registerForWeatherEmail(
                  emailController.text,
                  location: location,
                );
                setState(() {
                  isRegistering = false;
                  isSubmitted = true;
                  confirmationMessage =
                      'A confirmation email has been sent to ${emailController.text}. Please check your inbox to confirm your subscription for $location.';
                });
              } catch (e) {
                setState(() {
                  isRegistering = false;
                  isSubmitted = true;
                  confirmationMessage = 'Failed to register: ${e.toString()}';
                });
              }
            }

            Future<void> handleUnsubscribe() async {
              if (!formKey.currentState!.validate()) return;
              setState(() => isUnsubscribing = true);
              try {
                await emailService.unsubscribeFromWeatherEmail(
                  emailController.text,
                );
                setState(() {
                  isUnsubscribing = false;
                  isSubmitted = true;
                  confirmationMessage =
                      'A confirmation email to unsubscribe has been sent to ${emailController.text}. Please check your inbox to confirm.';
                });
              } catch (e) {
                setState(() {
                  isUnsubscribing = false;
                  isSubmitted = true;
                  confirmationMessage =
                      'Failed to unsubscribe: ${e.toString()}';
                });
              }
            }

            return AlertDialog(
              title: const Text('Daily Weather Email'),
              content:
                  isSubmitted
                      ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: Colors.blue,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            confirmationMessage ?? '',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                      : Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email address';
                                }
                                final emailRegex = RegExp(
                                  r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[\w-]{2,4}$',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        isRegistering
                                            ? null
                                            : () => handleRegister(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6286E6),
                                    ),
                                    child:
                                        isRegistering
                                            ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : const Text('Register'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed:
                                        isUnsubscribing
                                            ? null
                                            : () => handleUnsubscribe(),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                    child:
                                        isUnsubscribing
                                            ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.red),
                                              ),
                                            )
                                            : const Text(
                                              'Unsubscribe',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              actions: [
                if (!isSubmitted)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                if (isSubmitted)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLocationHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Access Help'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To use location features, please ensure:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Text('• The app is accessed via HTTPS (not HTTP)'),
              SizedBox(height: 4),
              Text('• Location permissions are granted in your browser'),
              SizedBox(height: 4),
              Text('• Location services are enabled on your device'),
              SizedBox(height: 4),
              Text('• Your browser supports geolocation API'),
              SizedBox(height: 12),
              Text(
                'If the issue persists, try refreshing the page or using a different browser.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a City Name',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'E.g., New York, London, Tokyo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isSearching)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _hideSuggestions();
                      },
                    ),
                  ],
                ),
              ),
              onSubmitted: (_) => _searchWeather(),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Consumer<WeatherProvider>(
                builder: (context, weatherProvider, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6286E6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed:
                        weatherProvider.isLoading ? null : _searchWeather,
                    child:
                        weatherProvider.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Search',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('or'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
                child:
                    _isGettingLocation
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Use Current Location',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
              ),
            ),

            // Weather History Section - moved here
            Consumer<WeatherProvider>(
              builder: (context, weatherProvider, child) {
                if (weatherProvider.weatherHistory.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Recent Searches'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Weather History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            weatherProvider.clearHistory();
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: weatherProvider.weatherHistory.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final historyEntry =
                              weatherProvider.weatherHistory[index];
                          final city = historyEntry['city'] ?? 'Unknown City';
                          final timestamp = DateTime.parse(
                            historyEntry['timestamp'],
                          );
                          final timeAgo = _getTimeAgo(timestamp);
                          final weather = historyEntry['weather'];
                          final temp =
                              weather['current']?['temp_c']?.toStringAsFixed(
                                1,
                              ) ??
                              '--';
                          final condition =
                              weather['current']?['condition']?['text'] ?? '';

                          return InkWell(
                            onTap: () {
                              weatherProvider.loadHistoryWeather(historyEntry);
                              _controller.text = city;
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.history,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          city,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (condition.isNotEmpty)
                                          Text(
                                            condition,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${temp}°C',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Text(
                                        timeAgo,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            // Email Subscription Section
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Daily Forecast'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF6286E6)),
                ),
                onPressed: () => _showEmailSubscriptionDialog(),
                icon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF6286E6),
                ),
                label: const Text(
                  'Get Daily Weather via Email',
                  style: TextStyle(fontSize: 16, color: Color(0xFF6286E6)),
                ),
              ),
            ),
          ],
        ),
        if (_showSuggestions)
          Positioned(
            top: 75,
            left: 0,
            right: 0,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  separatorBuilder:
                      (context, index) =>
                          Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    final name = suggestion['name'] ?? '';
                    final region = suggestion['region'] ?? '';
                    final country = suggestion['country'] ?? '';

                    String displayText = name;
                    if (region.isNotEmpty && region != name) {
                      displayText += ', $region';
                    }
                    if (country.isNotEmpty) {
                      displayText += ', $country';
                    }

                    return GestureDetector(
                      onTap: () {
                        _selectSuggestion(displayText);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                displayText,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

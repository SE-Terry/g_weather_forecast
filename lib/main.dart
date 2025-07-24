import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/weather_provider.dart';
import 'theme.dart';
import 'sections/search-section/search_section.dart';
import 'sections/forecast-section/forecast_section.dart';
import 'widgets/main_weather_card.dart';
import 'sections/details-dialog/details_dialog.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await dotenv.load(fileName: 'web/web.env');
    } else {
      await dotenv.load(fileName: '.env');
    }
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: MaterialApp(
        title: 'Weather Dashboard',
        theme: appTheme,
        home: const WeatherDashboard(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class WeatherDashboard extends StatelessWidget {
  const WeatherDashboard({super.key});

  String _getWeatherIconUrl(Map<String, dynamic> condition) {
    final iconPath = condition['icon'] ?? '';
    if (iconPath.isNotEmpty) {
      // Ensure the URL has https protocol
      return iconPath.startsWith('//') ? 'https:$iconPath' : iconPath;
    }
    return 'https://cdn.weatherapi.com/weather/64x64/day/116.png'; // Default partly cloudy icon
  }

  String _buildLocationTooltip(Map<String, dynamic> location) {
    final region =
        location['region']?.isNotEmpty == true ? ', ${location['region']}' : '';
    return 'Location: ${location['name']}$region, ${location['country']}\n'
        'Coordinates: ${location['lat']?.toStringAsFixed(4) ?? 'N/A'}, ${location['lon']?.toStringAsFixed(4) ?? 'N/A'}\n'
        'Timezone: ${location['tz_id'] ?? 'N/A'}\n'
        'Local Time: ${location['localtime'] ?? 'N/A'}';
  }

  void _showCurrentDayModal(
    BuildContext context,
    WeatherProvider weatherProvider,
  ) {
    if (weatherProvider.forecastDays.isNotEmpty) {
      final todayData = weatherProvider.forecastDays.first;
      final hourlyData = todayData['hour'] ?? [];
      final astroData = todayData['astro'];
      final date =
          todayData['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      final city =
          '${weatherProvider.location!['name']}, ${weatherProvider.location!['country']}';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DetailModal(
            date: date,
            city: city,
            hourlyData: hourlyData,
            astroData: astroData,
            dayData: todayData['day'],
            currentData: weatherProvider.currentWeather,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Sticky header
          Container(
            width: double.infinity,
            color: const Color(0xFF6286E6),
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: const Center(
              child: Text(
                'Weather Dashboard',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Search section (25%)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: const SearchSection(),
                  ),
                  const SizedBox(width: 16),
                  // Right: Weather display section (75%)
                  Expanded(
                    child: Consumer<WeatherProvider>(
                      builder: (context, weatherProvider, child) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Current weather card
                              if (weatherProvider.currentWeather != null &&
                                  weatherProvider.location != null) ...[
                                MainWeatherCard(
                                  city:
                                      '${weatherProvider.location!['name']}, ${weatherProvider.location!['country']}',
                                  date: DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(DateTime.now()),
                                  temperature:
                                      '${weatherProvider.currentWeather!['temp_c']?.toStringAsFixed(1) ?? '0.0'}°C',
                                  wind:
                                      '${weatherProvider.currentWeather!['wind_kph']?.toStringAsFixed(1) ?? '0.0'} km/h',
                                  humidity:
                                      '${weatherProvider.currentWeather!['humidity']?.toInt() ?? 0}%',
                                  condition:
                                      weatherProvider
                                          .currentWeather!['condition']['text'] ??
                                      'Unknown',
                                  icon: NetworkImage(
                                    _getWeatherIconUrl(
                                      weatherProvider
                                              .currentWeather!['condition'] ??
                                          {},
                                    ),
                                  ),
                                  titleFontSize: 26,
                                  dateFontSize: 18,
                                  infoFontSize: 18,
                                  iconSize: 80,
                                  condFontSize: 18,
                                  tooltipMessage: _buildLocationTooltip(
                                    weatherProvider.location!,
                                  ),
                                  onTap:
                                      () => _showCurrentDayModal(
                                        context,
                                        weatherProvider,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 32),
                              // Forecast section
                              const ForecastSection(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

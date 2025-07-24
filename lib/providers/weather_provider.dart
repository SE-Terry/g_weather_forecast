import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/weather_api_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherApiService _api = WeatherApiService();
  String city = 'Ho Chi Minh City';
  bool isLoading = false;
  String? error;
  Map<String, dynamic>? currentWeather;
  Map<String, dynamic>? location;
  List<dynamic> forecastDays = [];
  int forecastShown = 4;
  int totalForecast = 13;
  List<Map<String, dynamic>> weatherHistory = [];

  WeatherProvider() {
    _loadWeatherHistory();
    fetchWeather();
  }

  List<dynamic> get forecastDaysAfterToday =>
      forecastDays.length > 1 ? forecastDays.sublist(1) : [];

  Future<void> _loadWeatherHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('weather_history');
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        weatherHistory = historyList.cast<Map<String, dynamic>>();

        // Remove entries older than 24 hours
        final now = DateTime.now();
        weatherHistory =
            weatherHistory.where((entry) {
              final timestamp = DateTime.parse(entry['timestamp']);
              return now.difference(timestamp).inHours < 24;
            }).toList();

        // Save cleaned history
        await _saveWeatherHistory();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading weather history: $e');
    }
  }

  Future<void> _saveWeatherHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(weatherHistory);
      await prefs.setString('weather_history', historyJson);
    } catch (e) {
      debugPrint('Error saving weather history: $e');
    }
  }

  Future<void> _addToHistory(
    String cityName,
    Map<String, dynamic> weatherData,
  ) async {
    final historyEntry = {
      'city': cityName,
      'timestamp': DateTime.now().toIso8601String(),
      'weather': weatherData,
    };

    // Remove existing entry for the same city if it exists
    weatherHistory.removeWhere((entry) => entry['city'] == cityName);

    // Add new entry at the beginning
    weatherHistory.insert(0, historyEntry);

    // Keep only last 10 entries
    if (weatherHistory.length > 10) {
      weatherHistory = weatherHistory.take(10).toList();
    }

    await _saveWeatherHistory();
    notifyListeners();
  }

  Future<void> fetchWeather([String? newCity]) async {
    isLoading = true;
    error = null;
    notifyListeners();

    if (newCity != null && newCity.isNotEmpty) {
      city = newCity;
    }

    try {
      final forecastData = await _api.getForecast(city, days: totalForecast);
      if (forecastData == null) {
        error =
            'No data found for "$city". Please check the city name and try again.';
        isLoading = false;
        notifyListeners();
        return;
      }

      currentWeather = forecastData['current'];
      location = forecastData['location'];
      forecastDays = forecastData['forecast']['forecastday'] ?? [];
      isLoading = false;
      forecastShown = 4;
      error = null;

      // Add to history
      final cityName = '${location!['name']}, ${location!['country']}';
      await _addToHistory(cityName, {
        'current': currentWeather,
        'location': location,
        'forecast': forecastDays, // Save all forecast days, not just 4
      });

      notifyListeners();
    } catch (e) {
      error =
          'Failed to fetch weather data. Please check your internet connection and try again.';
      isLoading = false;
      notifyListeners();
      debugPrint('Weather fetch error: $e');
    }
  }

  Future<void> loadHistoryWeather(Map<String, dynamic> historyEntry) async {
    try {
      final weatherData = historyEntry['weather'];
      currentWeather = weatherData['current'];
      location = weatherData['location'];
      forecastDays = weatherData['forecast'] ?? [];
      city = historyEntry['city'];
      forecastShown = 4;
      error = null;
      notifyListeners();
    } catch (e) {
      error = 'Failed to load weather history';
      notifyListeners();
      debugPrint('History load error: $e');
    }
  }

  void loadMore() {
    final afterToday = forecastDaysAfterToday;
    if (forecastShown < afterToday.length) {
      forecastShown = (forecastShown + 4).clamp(0, afterToday.length);
      notifyListeners();
    }
  }

  void clearHistory() async {
    weatherHistory.clear();
    await _saveWeatherHistory();
    notifyListeners();
  }
}

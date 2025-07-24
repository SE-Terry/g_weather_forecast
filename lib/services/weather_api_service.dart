import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherApiService {
  static String get _apiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.weatherapi.com/v1';

  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.trim().isEmpty || query.trim().length < 3) {
      return [];
    }

    final url = Uri.parse(
      '$_baseUrl/search.json?key=$_apiKey&q=${Uri.encodeComponent(query.trim())}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        return results.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCurrentWeather(String city) async {
    final url = Uri.parse(
      '$_baseUrl/current.json?key=$_apiKey&q=$city&alerts=yes&aqi=yes',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getForecast(String city, {int days = 6}) async {
    final url = Uri.parse(
      '$_baseUrl/forecast.json?key=$_apiKey&q=$city&days=$days&alerts=yes&aqi=yes',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }
}

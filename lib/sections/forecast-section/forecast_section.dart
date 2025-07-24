import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/forecast_weather_card.dart';
import '../details-dialog/details_dialog.dart';
import 'package:intl/intl.dart';

class ForecastSection extends StatelessWidget {
  const ForecastSection({super.key});

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

  void _showDetailModal(
    BuildContext context,
    Map<String, dynamic> dayData,
    Map<String, dynamic> location,
  ) {
    final hourlyData = dayData['hour'] ?? [];
    final astroData = dayData['astro'];
    final date = dayData['date'] ?? '';
    final city = '${location['name']}, ${location['country']}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DetailModal(
          date: date,
          city: city,
          hourlyData: hourlyData,
          astroData: astroData,
          dayData: dayData['day'],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6286E6)),
            ),
          );
        }

        if (weatherProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  weatherProvider.error!,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => weatherProvider.fetchWeather(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6286E6),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final forecastDays = weatherProvider.forecastDaysAfterToday;
        final shownDays =
            forecastDays.take(weatherProvider.forecastShown).toList();

        if (shownDays.isEmpty) {
          return const Center(
            child: Text(
              'No forecast data available',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${shownDays.length}-Day Forecast',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final cardsPerRow =
                    screenWidth > 800 ? 4 : (screenWidth > 600 ? 3 : 2);
                final totalSpacing =
                    (cardsPerRow - 1) * 16; // spacing between cards
                final cardWidth = (screenWidth - totalSpacing) / cardsPerRow;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children:
                      shownDays.map((day) {
                        final date = DateTime.parse(day['date']);
                        final formattedDate = DateFormat(
                          'yyyy-MM-dd',
                        ).format(date);
                        final conditionObj = day['day']['condition'] ?? {};
                        final condition = conditionObj['text'] ?? 'Unknown';
                        final temp =
                            '${day['day']['avgtemp_c']?.toStringAsFixed(1) ?? '0.0'}°C';
                        final wind =
                            '${day['day']['maxwind_kph']?.toStringAsFixed(1) ?? '0.0'} km/h';
                        final humidity =
                            '${day['day']['avghumidity']?.toInt() ?? 0}%';

                        return ForecastWeatherCard(
                          date: formattedDate,
                          icon: NetworkImage(_getWeatherIconUrl(conditionObj)),
                          temp: temp,
                          wind: wind,
                          humidity: humidity,
                          width: cardWidth.clamp(180, double.infinity),
                          fontSize: 14,
                          titleFontSize: 16,
                          iconSize: 32,
                          dateTooltip: condition,
                          locationTooltip: _buildLocationTooltip(
                            weatherProvider.location!,
                          ),
                          onTap:
                              () => _showDetailModal(
                                context,
                                day,
                                weatherProvider.location!,
                              ),
                        );
                      }).toList(),
                );
              },
            ),
            if (weatherProvider.forecastShown < forecastDays.length) ...[
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: weatherProvider.loadMore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6286E6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Load More',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

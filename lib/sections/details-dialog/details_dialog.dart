import 'package:flutter/material.dart';
import '../../widgets/details-information/daily_summary_forecast.dart';
import '../../widgets/details-information/astro_forecast.dart';
import '../../widgets/details-information/hourly_forecast.dart';

class DetailModal extends StatelessWidget {
  final String date;
  final String city;
  final List<dynamic> hourlyData;
  final Map<String, dynamic>? astroData;
  final Map<String, dynamic>? dayData;
  final Map<String, dynamic>? currentData;

  const DetailModal({
    super.key,
    required this.date,
    required this.city,
    required this.hourlyData,
    this.astroData,
    this.dayData,
    this.currentData,
  });

  String _getWeatherIconUrl(Map<String, dynamic> condition) {
    final iconPath = condition['icon'] ?? '';
    if (iconPath.isNotEmpty) {
      return iconPath.startsWith('//') ? 'https:$iconPath' : iconPath;
    }
    return 'https://cdn.weatherapi.com/weather/64x64/day/116.png';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hourly Weather',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$city - $date',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  iconSize: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Daily Summary (if available)
            if (dayData != null) ...[
              DailySummaryForecast(
                dayData: dayData,
                getWeatherIconUrl: _getWeatherIconUrl,
              ),
              const SizedBox(height: 16),
            ],

            // Weather Alerts (if available)
            if (currentData != null && currentData!['alerts'] != null) ...[
              _buildWeatherAlerts(),
              const SizedBox(height: 16),
            ],

            // Astro information (if available)
            if (astroData != null) ...[
              AstroForecast(astroData: astroData),
              const SizedBox(height: 16),
            ],

            // Hourly data list
            HourlyForecast(
              hourlyData: hourlyData,
              getWeatherIconUrl: _getWeatherIconUrl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherAlerts() {
    if (currentData == null) return const SizedBox.shrink();

    final alerts = currentData!['alerts'];
    if (alerts == null || alerts['alert'] == null || alerts['alert'].isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather Alerts',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          ...alerts['alert'].map<Widget>((alert) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert['headline'] ?? 'Weather Alert',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  if (alert['desc'] != null) ...[
                    const SizedBox(height: 4),
                    Text(alert['desc'], style: const TextStyle(fontSize: 12)),
                  ],
                  if (alert['effective'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Effective: ${alert['effective']}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class DailySummaryForecast extends StatelessWidget {
  final Map<String, dynamic>? dayData;
  final String Function(Map<String, dynamic>) getWeatherIconUrl;

  const DailySummaryForecast({
    super.key,
    this.dayData,
    required this.getWeatherIconUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (dayData == null) return const SizedBox.shrink();

    final maxTemp = '${dayData!['maxtemp_c']?.toStringAsFixed(1) ?? 'N/A'}°C';
    final minTemp = '${dayData!['mintemp_c']?.toStringAsFixed(1) ?? 'N/A'}°C';
    final avgTemp = '${dayData!['avgtemp_c']?.toStringAsFixed(1) ?? 'N/A'}°C';
    final maxWind =
        '${dayData!['maxwind_kph']?.toStringAsFixed(1) ?? 'N/A'} km/h';
    final totalPrecip =
        '${dayData!['totalprecip_mm']?.toStringAsFixed(1) ?? '0.0'} mm';
    final totalSnow =
        '${dayData!['totalsnow_cm']?.toStringAsFixed(1) ?? '0.0'} cm';
    final avgHumidity = '${dayData!['avghumidity']?.toInt() ?? 0}%';
    final condition = dayData!['condition']['text'] ?? 'Unknown';
    final conditionIcon = dayData!['condition']['icon'] ?? '';
    final avgVisibility =
        '${dayData!['avgvis_km']?.toStringAsFixed(1) ?? 'N/A'} km';
    final uv = dayData!['uv']?.toStringAsFixed(1) ?? 'N/A';
    final chanceOfRain = '${dayData!['daily_chance_of_rain']?.toInt() ?? 0}%';
    final chanceOfSnow = '${dayData!['daily_chance_of_snow']?.toInt() ?? 0}%';
    final willRain = dayData!['daily_will_it_rain'] == 1 ? 'Yes' : 'No';
    final willSnow = dayData!['daily_will_it_snow'] == 1 ? 'Yes' : 'No';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Summary - $condition',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              if (conditionIcon.isNotEmpty)
                Image.network(
                  getWeatherIconUrl({'icon': conditionIcon}),
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.cloud,
                      size: 32,
                      color: Colors.green,
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),

          // First Row - 5 items
          Row(
            children: [
              Expanded(
                child: _buildSummaryItemWithIcon(
                  Icons.thermostat,
                  'Min Temp',
                  minTemp,
                ),
              ),
              Expanded(
                child: _buildSummaryItemWithIcon(
                  Icons.thermostat,
                  'Max Temp',
                  maxTemp,
                ),
              ),
              Expanded(
                child: _buildSummaryItemWithIcon(
                  Icons.wb_sunny,
                  'UV Index',
                  uv,
                ),
              ),
              Expanded(
                child: _buildSummaryItemWithIcon(
                  Icons.water,
                  'Total Rain',
                  totalPrecip,
                ),
              ),
              Expanded(
                child: _buildSummaryItemWithIcon(
                  Icons.umbrella,
                  'Will Rain',
                  willRain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Second Row - 5 items
          Row(
            children: [
              Expanded(
                child: _buildSummaryItemWithIcon(
                  Icons.grain,
                  'Rain Chance',
                  chanceOfRain,
                ),
              ),
              Expanded(
                child: _buildSummaryItemWithIcon(
                  Icons.snowing,
                  'Will Snow',
                  willSnow,
                ),
              ),
              Expanded(
                child: _buildSummaryItemWithIcon(
                  Icons.snowing,
                  'Snow Chance',
                  chanceOfSnow,
                ),
              ),
              Expanded(
                child: _buildSummaryItemWithIcon(
                  Icons.air,
                  'Max Wind',
                  maxWind,
                ),
              ),
              Expanded(
                child: _buildSummaryItemWithIcon(
                  Icons.ac_unit,
                  'Total Snow',
                  totalSnow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Third Row - 3 items
          Row(
            children: [
              Expanded(
                child: _buildSummaryItemWithIcon(
                  Icons.thermostat,
                  'Avg Temp',
                  avgTemp,
                ),
              ),
              Expanded(
                child: _buildSummaryItemWithIcon(
                  Icons.water_drop,
                  'Avg Humidity',
                  avgHumidity,
                ),
              ),
              Expanded(
                child: _buildSummaryItemWithIcon(
                  Icons.visibility,
                  'Avg Visibility',
                  avgVisibility,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItemWithIcon(IconData icon, String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: Colors.green.shade700),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

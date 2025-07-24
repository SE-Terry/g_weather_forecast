import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'aqi_hourly_forecast.dart';

class HourlyForecast extends StatelessWidget {
  final List<dynamic> hourlyData;
  final String Function(Map<String, dynamic>) getWeatherIconUrl;

  const HourlyForecast({
    super.key,
    required this.hourlyData,
    required this.getWeatherIconUrl,
  });

  String _formatTime(String timeString) {
    try {
      final DateTime dateTime = DateTime.parse(timeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return timeString.split(' ').last;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: hourlyData.length,
        itemBuilder: (context, index) {
          final hour = hourlyData[index];
          return _buildHourlyItem(hour);
        },
      ),
    );
  }

  Widget _buildHourlyItem(Map<String, dynamic> hour) {
    final time = _formatTime(hour['time'] ?? '');
    final temp = '${hour['temp_c']?.toStringAsFixed(1) ?? '0.0'}°C';
    final feelsLike = '${hour['feelslike_c']?.toStringAsFixed(1) ?? '0.0'}°C';
    final condition = hour['condition']['text'] ?? 'Unknown';
    final humidity = '${hour['humidity']?.toInt() ?? 0}%';
    final windSpeed = '${hour['wind_kph']?.toStringAsFixed(1) ?? '0.0'} km/h';
    final windDir = hour['wind_dir'] ?? 'N/A';
    final windDegree = '${hour['wind_degree']?.toInt() ?? 0}°';
    final pressure = '${hour['pressure_mb']?.toInt() ?? 0} mb';
    final visibility = '${hour['vis_km']?.toInt() ?? 0} km';
    final uv = hour['uv']?.toStringAsFixed(1) ?? '0.0';
    final chanceOfRain = '${hour['chance_of_rain']?.toInt() ?? 0}%';
    final chanceOfSnow = '${hour['chance_of_snow']?.toInt() ?? 0}%';
    final gustSpeed = '${hour['gust_kph']?.toStringAsFixed(1) ?? '0.0'} km/h';
    final dewpoint = '${hour['dewpoint_c']?.toStringAsFixed(1) ?? '0.0'}°C';
    final heatIndex = '${hour['heatindex_c']?.toStringAsFixed(1) ?? '0.0'}°C';
    final windChill = '${hour['windchill_c']?.toStringAsFixed(1) ?? '0.0'}°C';
    final cloud = '${hour['cloud']?.toInt() ?? 0}%';
    final precipMm = '${hour['precip_mm']?.toStringAsFixed(1) ?? '0.0'} mm';
    final snowCm = '${hour['snow_cm']?.toStringAsFixed(1) ?? '0.0'} cm';
    final willRain = hour['will_it_rain'] == 1 ? 'Yes' : 'No';
    final willSnow = hour['will_it_snow'] == 1 ? 'Yes' : 'No';
    final shortRad = '${hour['short_rad']?.toStringAsFixed(1) ?? '0.0'} W/m²';
    final diffRad = '${hour['diff_rad']?.toStringAsFixed(1) ?? '0.0'} W/m²';

    // Air Quality data
    final aqi = hour['air_quality'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Time and main weather info
          Row(
            children: [
              // Time
              SizedBox(
                width: 60,
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Weather icon
              Image.network(
                getWeatherIconUrl(hour['condition'] ?? {}),
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.cloud, size: 32);
                },
              ),
              const SizedBox(width: 16),

              // Temperature and condition
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          temp,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    Text(condition, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Temperature & Feel
          Row(
            children: [
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.thermostat,
                  'Feels Like',
                  feelsLike,
                ),
              ),
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.thermostat,
                  'Dewpoint',
                  dewpoint,
                ),
              ),
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.local_fire_department,
                  'Heat Index',
                  heatIndex,
                ),
              ),
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.ac_unit,
                  'Wind Chill',
                  windChill,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Wind Information
          Row(
            children: [
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.air,
                  'Wind Speed',
                  windSpeed,
                ),
              ),
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.navigation,
                  'Wind Dir',
                  '$windDir ($windDegree)',
                ),
              ),
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.tornado,
                  'Wind Gust',
                  gustSpeed,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Atmospheric Conditions
          Row(
            children: [
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.cloud,
                  'Cloud Cover',
                  cloud,
                ),
              ),
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.water_drop,
                  'Humidity',
                  humidity,
                ),
              ),
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.compress,
                  'Pressure',
                  pressure,
                ),
              ),
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.visibility,
                  'Visibility',
                  visibility,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // UV & Precipitation
          Row(
            children: [
              Expanded(
                child: _buildDetailItemWithIcon(Icons.wb_sunny, 'UV Index', uv),
              ),
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.water,
                  'Precipitation',
                  precipMm,
                ),
              ),
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.ac_unit,
                  'Snowfall',
                  snowCm,
                ),
              ),
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.grain,
                  'Rain Chance',
                  chanceOfRain,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Rain & Snow Predictions
          Row(
            children: [
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.snowing,
                  'Snow Chance',
                  chanceOfSnow,
                ),
              ),
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.umbrella,
                  'Will Rain',
                  willRain,
                ),
              ),
              Expanded(
                child: _buildDetailItemWithIcon(
                  Icons.snowing,
                  'Will Snow',
                  willSnow,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Solar Radiation (if available)
          if (hour['short_rad'] != null || hour['diff_rad'] != null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildDetailItemWithIcon(
                    Icons.light_mode,
                    'Solar Rad',
                    shortRad,
                  ),
                ),
                Expanded(
                  child: _buildDetailItemWithIcon(
                    Icons.flare,
                    'Diffuse Rad',
                    diffRad,
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Air Quality section (if available)
          if (aqi != null) ...[
            const SizedBox(height: 12),
            AQIHourlyForecast(aqi: aqi),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItemWithIcon(IconData icon, String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.blue.shade600),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

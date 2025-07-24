import 'package:flutter/material.dart';

class AQIHourlyForecast extends StatelessWidget {
  final Map<String, dynamic>? aqi;

  const AQIHourlyForecast({super.key, this.aqi});

  @override
  Widget build(BuildContext context) {
    if (aqi == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.air, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                'Air Quality Index',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Pollutant Concentrations
          Row(
            children: [
              Expanded(
                child: _buildAQIItemWithIcon(
                  Icons.local_gas_station,
                  'CO',
                  '${aqi!['co']?.toStringAsFixed(1) ?? 'N/A'} μg/m³',
                ),
              ),
              Expanded(
                child: _buildAQIItemWithIcon(
                  Icons.local_gas_station,
                  'NO₂',
                  '${aqi!['no2']?.toStringAsFixed(1) ?? 'N/A'} μg/m³',
                ),
              ),
              Expanded(
                child: _buildAQIItemWithIcon(
                  Icons.local_gas_station,
                  'O₃',
                  '${aqi!['o3']?.toStringAsFixed(1) ?? 'N/A'} μg/m³',
                ),
              ),
              Expanded(
                child: _buildAQIItemWithIcon(
                  Icons.local_gas_station,
                  'SO₂',
                  '${aqi!['so2']?.toStringAsFixed(1) ?? 'N/A'} μg/m³',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Particulate Matter & Indices
          Row(
            children: [
              Expanded(
                child: _buildAQIItemWithIcon(
                  Icons.blur_on,
                  'PM2.5',
                  '${aqi!['pm2_5']?.toStringAsFixed(1) ?? 'N/A'} μg/m³',
                ),
              ),
              Expanded(
                child: _buildAQIItemWithIcon(
                  Icons.blur_circular,
                  'PM10',
                  '${aqi!['pm10']?.toStringAsFixed(1) ?? 'N/A'} μg/m³',
                ),
              ),
              Expanded(
                child: _buildAQIItemWithIcon(
                  Icons.assessment,
                  'US EPA',
                  '${aqi!['us-epa-index']?.toInt() ?? 'N/A'} - ${_getEPAMeaning(aqi!['us-epa-index']?.toInt() ?? 0)}',
                ),
              ),
              Expanded(
                child: _buildAQIItemWithIcon(
                  Icons.analytics,
                  'UK Defra',
                  '${aqi!['gb-defra-index']?.toInt() ?? 'N/A'} - ${_getDefraMenuing(aqi!['gb-defra-index']?.toInt() ?? 0)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAQIItemWithIcon(IconData icon, String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: Colors.orange.shade700),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getEPAMeaning(int index) {
    switch (index) {
      case 1:
        return 'Good';
      case 2:
        return 'Moderate';
      case 3:
        return 'Unhealthy for Sensitive';
      case 4:
        return 'Unhealthy';
      case 5:
        return 'Very Unhealthy';
      case 6:
        return 'Hazardous';
      default:
        return 'Unknown';
    }
  }

  String _getDefraMenuing(int index) {
    switch (index) {
      case 1:
      case 2:
      case 3:
        return 'Low';
      case 4:
      case 5:
      case 6:
        return 'Moderate';
      case 7:
      case 8:
      case 9:
        return 'High';
      case 10:
        return 'Very High';
      default:
        return 'Unknown';
    }
  }
}

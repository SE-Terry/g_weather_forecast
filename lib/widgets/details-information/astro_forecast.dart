import 'package:flutter/material.dart';

class AstroForecast extends StatelessWidget {
  final Map<String, dynamic>? astroData;

  const AstroForecast({super.key, this.astroData});

  @override
  Widget build(BuildContext context) {
    if (astroData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Sun information
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAstroItemWithIcon(
                Icons.wb_sunny,
                'Sunrise',
                astroData!['sunrise'] ?? 'N/A',
              ),
              _buildAstroItemWithIcon(
                Icons.wb_twilight,
                'Sunset',
                astroData!['sunset'] ?? 'N/A',
              ),
              _buildAstroItemWithIcon(
                Icons.brightness_3,
                'Moonrise',
                astroData!['moonrise'] ?? 'N/A',
              ),
              _buildAstroItemWithIcon(
                Icons.brightness_1,
                'Moonset',
                astroData!['moonset'] ?? 'N/A',
              ),
              _buildAstroItemWithIcon(
                Icons.nightlight,
                'Moon Phase',
                astroData!['moon_phase'] ?? 'N/A',
              ),
              _buildAstroItemWithIcon(
                Icons.brightness_medium,
                'Moon Light',
                '${astroData!['moon_illumination']?.toString() ?? '0'}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAstroItemWithIcon(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.blue.shade600),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

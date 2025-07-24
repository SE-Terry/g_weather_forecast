import 'package:flutter/material.dart';

class MainWeatherCard extends StatelessWidget {
  final String city;
  final String date;
  final String temperature;
  final String wind;
  final String humidity;
  final String condition;
  final dynamic icon; // Accept IconData, ImageProvider, or String (emoji)
  final double titleFontSize;
  final double dateFontSize;
  final double infoFontSize;
  final double iconSize;
  final double condFontSize;
  final String? tooltipMessage;
  final VoidCallback? onTap;

  const MainWeatherCard({
    super.key,
    required this.city,
    required this.date,
    required this.temperature,
    required this.wind,
    required this.humidity,
    required this.condition,
    required this.icon,
    required this.titleFontSize,
    required this.dateFontSize,
    required this.infoFontSize,
    required this.iconSize,
    required this.condFontSize,
    this.tooltipMessage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    if (icon is IconData) {
      iconWidget = Icon(icon, size: iconSize, color: Colors.white);
    } else if (icon is ImageProvider) {
      iconWidget = Image(
        image: icon,
        width: iconSize,
        height: iconSize,
        color: Colors.white,
        colorBlendMode: BlendMode.srcIn,
      );
    } else if (icon is String) {
      iconWidget = Text(icon, style: TextStyle(fontSize: iconSize));
    } else {
      iconWidget = Icon(Icons.cloud, size: iconSize, color: Colors.white);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF6286E6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Weather info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tooltip(
                    message: tooltipMessage ?? '',
                    child: Text(
                      '$city ($date)',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Temperature: $temperature',
                    style: TextStyle(
                      fontSize: infoFontSize,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Wind: $wind',
                    style: TextStyle(
                      fontSize: infoFontSize,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Humidity: $humidity',
                    style: TextStyle(
                      fontSize: infoFontSize,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Right: Icon and condition
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Tooltip(message: condition, child: iconWidget),
                const SizedBox(height: 8),
                SizedBox(
                  width: 120,
                  child: Text(
                    condition,
                    style: TextStyle(
                      fontSize: condFontSize,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

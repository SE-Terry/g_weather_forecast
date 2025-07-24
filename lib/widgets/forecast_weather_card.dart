import 'package:flutter/material.dart';

class ForecastWeatherCard extends StatelessWidget {
  final String date;
  final dynamic icon; // Accept IconData, ImageProvider, or String (emoji)
  final String temp;
  final String wind;
  final String humidity;
  final double width;
  final double fontSize;
  final double titleFontSize;
  final double iconSize;
  final String? dateTooltip;
  final String? locationTooltip;
  final VoidCallback? onTap;

  const ForecastWeatherCard({
    super.key,
    required this.date,
    required this.icon,
    required this.temp,
    required this.wind,
    required this.humidity,
    required this.width,
    required this.fontSize,
    required this.titleFontSize,
    required this.iconSize,
    this.dateTooltip,
    this.locationTooltip,
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
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tooltip(
              message: locationTooltip ?? '',
              child: Text(
                date,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                softWrap: true,
              ),
            ),
            const SizedBox(height: 12),
            Tooltip(message: dateTooltip ?? '', child: iconWidget),
            const SizedBox(height: 12),
            Text(
              'Temp: $temp',
              style: TextStyle(color: Colors.white, fontSize: fontSize),
            ),
            Text(
              'Wind: $wind',
              style: TextStyle(color: Colors.white, fontSize: fontSize),
            ),
            Text(
              'Humidity: $humidity',
              style: TextStyle(color: Colors.white, fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }
}

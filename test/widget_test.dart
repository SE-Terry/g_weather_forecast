import 'package:flutter_test/flutter_test.dart';
import 'package:g_weather_forecast/main.dart';

void main() {
  testWidgets('Weather app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WeatherApp());

    // Verify that the weather dashboard title is present
    expect(find.text('Weather Dashboard'), findsOneWidget);

    // Verify that the search section is present
    expect(find.text('Enter a City Name'), findsOneWidget);

    // Verify that search button is present
    expect(find.text('Search'), findsOneWidget);

    // Verify that current location button is present
    expect(find.text('Use Current Location'), findsOneWidget);
  });
}

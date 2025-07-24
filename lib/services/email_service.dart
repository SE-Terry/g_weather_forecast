import 'package:cloud_functions/cloud_functions.dart';

class EmailService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> registerForWeatherEmail(String email, {String? location}) async {
    final HttpsCallable callable = _functions.httpsCallable(
      'registerWeatherEmail',
    );
    await callable.call(<String, dynamic>{
      'email': email,
      'location': location ?? 'your location',
    });
  }

  Future<void> unsubscribeFromWeatherEmail(String email) async {
    final HttpsCallable callable = _functions.httpsCallable(
      'unsubscribeWeatherEmail',
    );
    await callable.call(<String, dynamic>{'email': email});
  }
}

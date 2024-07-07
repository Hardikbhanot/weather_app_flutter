import 'package:shared_preferences/shared_preferences.dart';

class CityPreferences {
  static const _cityKey = 'last_city';

  static Future<void> saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, city);
  }

  static Future<String?> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cityKey);
  }
}

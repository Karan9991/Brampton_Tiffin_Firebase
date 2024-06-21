import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Store a string value in shared preferences
  static Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  // Get a string value from shared preferences
  static String? getString(String key) {
    return _prefs.getString(key);
  }

  // Store an int value in shared preferences
  static Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  // Get an int value from shared preferences
  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Store a boolean value in shared preferences
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  // Get a boolean value from shared preferences
  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

//  static bool getBool(String key, {bool defaultValue = false}) {
//     return _prefs.getBool(key) ?? defaultValue;
//   }
  // Remove a value from shared preferences
  static Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // Clear all data in shared preferences
  // static Future<bool> clear() async {
  //   return await _prefs.clear();
  // }

  static Future<bool> clear() async {
    final rememberMeEmail = _prefs!.getString('emaill');
    final rememberMePassword = _prefs!.getString('passwordd');
    final rememberMe = _prefs!.getBool('rememberMe');

    await _prefs!.clear();

    // Restore the email and password for the "Remember Me" functionality
    if (rememberMeEmail != null) {
      await _prefs!.setString('emaill', rememberMeEmail);
    }
    if (rememberMePassword != null) {
      await _prefs!.setString('passwordd', rememberMePassword);
    }
  if (rememberMe != null) {
      await _prefs!.setBool('rememberMe', rememberMe);
    }
    return true;
  }
}

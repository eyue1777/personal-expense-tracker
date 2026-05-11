import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _kCurrency = 'currency';
  static const _kDarkMode = 'dark_mode';

  Future<void> setCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrency, code);
  }

  Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kCurrency) ?? 'USD';
  }

  // FIXED: Added setTheme
  Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, isDark);
  }

  // FIXED: Added getTheme
  Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDarkMode) ?? false;
  }
}

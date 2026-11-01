import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const String _themeKey = 'theme_mode';

  final SharedPreferences _preferences;

  ThemeRepository(this._preferences);

  ThemeMode loadThemeMode() {
    final saved = _preferences.getString(_themeKey);
    return saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _preferences.setString(
      _themeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}
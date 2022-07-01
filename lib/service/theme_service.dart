
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String prefSelectedTheme = "SelectedTheme";

  Future<void> changeTheme(ThemeMode themeMode) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String themeModeName = '';
    switch (themeMode) {
      case ThemeMode.light:
        themeModeName = 'light';
        break;
      case ThemeMode.dark:
        themeModeName = 'dark';
        break;
      case ThemeMode.system:
      default:
        themeModeName = 'system';
    }
    await _prefs.setString(prefSelectedTheme, themeModeName);
  }

  Future<ThemeMode> loadTheme() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String theme = _prefs.getString(prefSelectedTheme) ?? 'light';
    switch (theme) {
      case 'dark' :
        return ThemeMode.dark;
      case 'light' :
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

}

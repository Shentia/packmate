import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  
  // Default theme is light
  static const Brightness defaultTheme = Brightness.light;
  
  // Get the saved theme mode
  Future<Brightness> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isLightMode = prefs.getBool(_themeKey) ?? true; // Default to light theme
    return isLightMode ? Brightness.light : Brightness.dark;
  }
  
  // Save the theme mode
  Future<void> setThemeMode(Brightness brightness) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, brightness == Brightness.light);
  }
  
  // Toggle between light and dark theme
  Future<Brightness> toggleThemeMode() async {
    final currentTheme = await getThemeMode();
    final newTheme = currentTheme == Brightness.light 
        ? Brightness.dark 
        : Brightness.light;
    await setThemeMode(newTheme);
    return newTheme;
  }
}
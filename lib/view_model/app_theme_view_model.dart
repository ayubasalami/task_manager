import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeViewModel() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);

      if (themeIndex != null && themeIndex < ThemeMode.values.length) {
        state = ThemeMode.values[themeIndex];
      }
    } catch (e) {
      state = ThemeMode.system;
    }
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _saveTheme(mode);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

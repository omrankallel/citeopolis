import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_app.dart';

final themeProvider = ChangeNotifierProvider((ref) => ThemeProvider());

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Brightness? _overriddenBrightness;

  void setOverrideBrightness(Brightness brightness) {
    if (_overriddenBrightness != brightness) {
      _overriddenBrightness = brightness;
      _updateThemeData();
      notifyListeners();
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get themeData {
    if (_themeMode == ThemeMode.system) {
      final brightness = _overriddenBrightness ??
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? darkTheme : lightTheme;
    }
    return _themeMode == ThemeMode.dark ? darkTheme : lightTheme;
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return (_overriddenBrightness ??
          WidgetsBinding.instance.platformDispatcher.platformBrightness) ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode');
    if (themeString != null) {
      if (themeString == 'light') {
        _themeMode = ThemeMode.light;
      } else if (themeString == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _updateThemeData();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';
    await prefs.setString('theme_mode', value);
  }

  void _updateThemeData() {
    if (_themeMode == ThemeMode.system) {
      final brightness = _overriddenBrightness ??
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
    } else {
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  void updateSystemTheme() {
    setThemeMode(ThemeMode.system);
  }

  void setThemeDataLight() {
    setThemeMode(ThemeMode.light);
  }

  void setThemeDataDark() {
    setThemeMode(ThemeMode.dark);
  }
}

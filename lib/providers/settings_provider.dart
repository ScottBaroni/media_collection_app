import 'package:flutter/material.dart';

enum AppTheme { light, dark }

class SettingsProvider extends ChangeNotifier {
  AppTheme _theme = AppTheme.light;

  AppTheme get theme => _theme;

  bool get isDark => _theme == AppTheme.dark;

  void setTheme(AppTheme theme) {
    _theme = theme;
    notifyListeners();
  }

  ThemeData get themeData {
    switch (_theme) {
      case AppTheme.light:
        return ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
        );
      case AppTheme.dark:
        return ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
        );
    }
  }
}
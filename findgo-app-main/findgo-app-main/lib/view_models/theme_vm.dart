import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../external_services/local_data_src.dart';

class ThemeViewModel extends ChangeNotifier {
  final LocalDataSource localDataSource;

  ThemeViewModel(
      {required this.localDataSource, ThemeMode mode = ThemeMode.light})
      : _mode = mode;
  ThemeMode _mode;
  ThemeMode get mode => _mode;

  Future<void> getThemeModeFromStorage() async {
    _mode = await localDataSource.themeMode;
  }

  final dark = ThemeData.dark().copyWith(
    primaryColorDark: kColorBackgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: kColorAccent,
      secondary: kColorAccent,
      background: kColorBackgroundDark,
      surface: kColorCardDark, // background of widgets / cards
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: kColorAccent,
        onPrimary: Colors.white,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    //cardColor: kColorCardDark,
    //focusColor: kColorAccent,¡
  );

  final light = ThemeData.light().copyWith(
    primaryColorDark: kColorBackgroundLight,
    primaryColor: Colors.white, // For app icon background
    colorScheme: const ColorScheme.light(
      primary: kColorAccent,
      secondary: kColorAccent,
      background: kColorBackgroundLight,
      surface: kColorCardLight, // background of widgets / cards
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: kColorAccent,
        onPrimary: Colors.black87,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    //cardColor: kColorCardLight,
    //focusColor: kColorAccent,
  );

  void toggleMode() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final theme = _mode == ThemeMode.light ? "light" : "dark";
    localDataSource.setTheme(theme);
    notifyListeners();
  }

  // ThemeData getTheme() {
  //   return _mode == ThemeViewMode.dark ? darkMode : lightMode;
  // }

}


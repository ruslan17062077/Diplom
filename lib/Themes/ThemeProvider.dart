import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode;

  // Constructor which takes in the bool, and initializes the themeMode accordingly
  ThemeProvider(bool initialIsDarkMode)
      : themeMode = initialIsDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() async {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    // also store it in the preferences (in case the app is closed after this)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', themeMode == ThemeMode.dark);

    notifyListeners();
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:molokosbor/Pages/Landing/landing.dart';
import 'package:molokosbor/Pages/map.dart';
import 'package:molokosbor/Themes/ThemeProvider.dart';
import 'package:molokosbor/Themes/theme.dart';
import 'package:molokosbor/router/routers.dart';

import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yandex_maps_mapkit_lite/init.dart' as init;
import 'package:yandex_maps_mapkit_lite/mapkit.dart';
import 'package:yandex_maps_mapkit_lite/yandex_map.dart';

/// Сервис для получения прогноза погоды с Open-Meteo и синхронизации с локальной БД.


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ijfnwqionlzjgqvwgbdd.supabase.co', // замените на ваш URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlqZm53cWlvbmx6amdxdndnYmRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMwNzE4NTMsImV4cCI6MjA1ODY0Nzg1M30.b3XR62XxzevBMAScC_sOjDH2-Fxko69uQTceNNO12zA',
    
    // замените на ваш анонимный ключ
  );
  WidgetsFlutterBinding.ensureInitialized();

  // await init.initMapkit(
  //   apiKey: '24fca1d8-2cd8-427b-b0f7-ae9147aa9795'
  // ); 
  runApp(MyApp(false));
}

class MyApp extends StatelessWidget {
  final bool initialIsDarkMode;
   MapWindow? _mapWindow;
   MyApp(
    this.initialIsDarkMode,
    {super.key}
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    
    create: (context) => ThemeProvider(initialIsDarkMode),
    builder: (context, child) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return MaterialApp(
    
        debugShowCheckedModeBanner: false,
        title: 'MolokoSbor',
        theme: lightTheme,
        darkTheme: themaDark,
        themeMode: themeProvider.themeMode,
         initialRoute: '/',
         routes: routes,
         onGenerateRoute: (settings) {
        final builder = parameterizedRoutes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        }}
      );
    }
  );
}
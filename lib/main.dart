import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Сервис для получения прогноза погоды с Open-Meteo и синхронизации с локальной БД.
class WeatherApiService {
  // URL тестового API (можно добавить параметры прямо в ссылку)
  final String url =
      'https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&hourly=temperature_2m,wind_direction_10m';

  final Database db;

  WeatherApiService({required this.db});

  /// Получает данные с API, преобразует и синхронизирует с локальной БД.
  Future<List<Map<String, dynamic>>> fetchAndSyncForecast() async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      // Преобразуем данные из "hourly" в список записей.
      final hourly = jsonData['hourly'];
      List<dynamic> times = hourly['time'];
      List<dynamic> temps = hourly['temperature_2m'];
      List<dynamic> winds = hourly['wind_direction_10m'];

      // Формируем список прогнозов.
      List<Map<String, dynamic>> forecastList = [];
      for (int i = 0; i < times.length; i++) {
        forecastList.add({
          'id': i, // используем индекс в качестве id
          'time': times[i],
          'temperature': temps[i],
          'wind_direction': winds[i],
        });
      }
      // Синхронизируем с локальной БД
      await _syncLocalForecast(forecastList);
      return forecastList;
    } else {
      throw Exception('Ошибка загрузки данных: ${response.statusCode}');
    }
  }

  /// Сохраняет прогноз в таблицу "forecast". Перед вставкой очищаем таблицу.
  Future<void> _syncLocalForecast(List<Map<String, dynamic>> data) async {
    await db.transaction((txn) async {
      // Очистка таблицы перед вставкой новых данных
      await txn.delete('forecast');
      for (var record in data) {
        await txn.insert('forecast', record);
      }
    });
  }
}

/// Тестовая страница для отображения прогноза погоды.
class WeatherTestPage extends StatefulWidget {
  const WeatherTestPage({Key? key}) : super(key: key);

  @override
  _WeatherTestPageState createState() => _WeatherTestPageState();
}

class _WeatherTestPageState extends State<WeatherTestPage> {
  late Database database;
  List<Map<String, dynamic>> forecast = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDbAndFetchForecast();
  }

  Future<void> _initDbAndFetchForecast() async {
    // Инициализация локальной БД
    final dbPath = await getDatabasesPath();
    database = await openDatabase(
      join(dbPath, 'weather.db'),
      onCreate: (db, version) async {
        // Создание таблицы для прогноза погоды
        await db.execute('''
          CREATE TABLE forecast (
            id INTEGER PRIMARY KEY,
            time TEXT,
            temperature REAL,
            wind_direction INTEGER
          )
        ''');
      },
      version: 1,
    );

    // Создаем экземпляр сервиса и запрашиваем данные
    final weatherService = WeatherApiService(db: database);
    try {
      List<Map<String, dynamic>> result =
      await weatherService.fetchAndSyncForecast();
      setState(() {
        forecast = result;
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Функция для обновления данных по нажатию кнопки
  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await _initDbAndFetchForecast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Прогноз погоды'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : forecast.isEmpty
          ? const Center(child: Text('Нет данных'))
          : ListView.builder(
        itemCount: forecast.length,
        itemBuilder: (context, index) {
          final item = forecast[index];
          return ListTile(
            leading: Text(item['id'].toString()),
            title: Text(item['time']),
            subtitle: Text(
              'Температура: ${item['temperature']}°C, Направление ветра: ${item['wind_direction']}°',
            ),
          );
        },
      ),
    );
  }
}

/// Точка входа приложения.
void main() {
  runApp(const MaterialApp(
    home: WeatherTestPage(),
  ));
}

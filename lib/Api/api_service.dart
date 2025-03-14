import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class ApiService {
  final String baseUrl;
  final Database db;

  ApiService({required this.baseUrl, required this.db});

  /// GET-запрос для получения данных по указанному endpoint.
  Future<List<dynamic>> getData(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // Синхронизация данных с локальной БД
      await _syncLocalTable(endpoint, data);
      return data;
    } else {
      throw Exception('Ошибка загрузки данных: ${response.statusCode}');
    }
  }

  /// POST-запрос для создания нового элемента.
  Future<Map<String, dynamic>> postData(String endpoint, Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> data = json.decode(response.body);
      // Синхронизация созданного элемента с локальной БД
      await _syncLocalItem(endpoint, data);
      return data;
    } else {
      throw Exception('Ошибка создания данных: ${response.statusCode}');
    }
  }

  /// PATCH-запрос для частичного обновления элемента.
  Future<Map<String, dynamic>> patchData(String endpoint, Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      // Обновление данных в локальной БД
      await _syncLocalItem(endpoint, data);
      return data;
    } else {
      throw Exception('Ошибка обновления данных: ${response.statusCode}');
    }
  }

  /// DELETE-запрос для удаления элемента.
  Future<void> deleteData(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      // Удаление данных из локальной БД
      await _deleteLocalItem(endpoint);
    } else {
      throw Exception('Ошибка удаления данных: ${response.statusCode}');
    }
  }

  /// Приватный метод для синхронизации списка данных с локальной таблицей.
  Future<void> _syncLocalTable(String tableName, List<dynamic> data) async {
    await db.transaction((txn) async {
      // Очистка таблицы перед синхронизацией
      await txn.delete(tableName);
      for (var item in data) {
        await txn.insert(tableName, Map<String, dynamic>.from(item));
      }
    });
  }

  /// Приватный метод для синхронизации одного элемента с локальной БД.
  Future<void> _syncLocalItem(String tableName, Map<String, dynamic> item) async {
    await db.transaction((txn) async {
      // Предполагаем, что у элемента есть поле 'id'
      final id = item['id'];
      // Проверяем, существует ли уже запись
      final result = await txn.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        // Обновление существующей записи
        await txn.update(
          tableName,
          item,
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        // Вставка новой записи
        await txn.insert(tableName, item);
      }
    });
  }

  /// Приватный метод для удаления элемента из локальной БД.
  /// Здесь предполагается, что endpoint имеет формат "tableName/id"
  Future<void> _deleteLocalItem(String endpoint) async {
    // Разбиваем endpoint, чтобы получить имя таблицы и идентификатор
    final parts = endpoint.split('/');
    if (parts.length == 2) {
      final tableName = parts[0];
      final id = parts[1];
      await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}

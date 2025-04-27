import 'package:molokosbor/DataBase/models/deliveries.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class DeliveryService {
  static final _client = Supabase.instance.client;

  Future<void> addDelivery(Delivery delivery) async{
    await _client.from('deliveries').insert(delivery.toJson());
  }

  /// Вычисляет дату следующей открытой доставки (без записей canceled/delivered)
  Future<DateTime> getNextDeliveryDate(String clientId) async {
    // Начинаем с сегодняшнего дня без времени
    DateTime date = DateTime.now();
    date = DateTime(date.year, date.month, date.day);

    while (true) {
      // Определяем границы для дня
      final start = date.toIso8601String();
      final nextDay = date.add(const Duration(days: 1));
      final end = nextDay.toIso8601String();

      // Ищем запись о сдаче или отмене в этот день
      final resp = await _client
          .from('deliveries')
          .select('status')
          .eq('client_id', clientId)
          .gte('delivery_time', start)
          .lt('delivery_time', end)
          .limit(1)
          .maybeSingle();

      if (resp == null) {
        // Нет записи — возвращаем эту дату
        return date;
      }
      // Есть запись (delivered или canceled) — проверяем следующий день
      date = nextDay;
    }
  }

  /// Отменяет запись на ближайшую доставку (первая найденная)
  Future<bool> cancelDelivery({
    required String clientId,
    String? collectorId,
    String? notes,
  }) async {
    // Находим ближайшую запись (первую), может быть canceled/delivered — любой статус
    final next = await getNextDeliveryDate(clientId);

    // Ищем запись именно на эту дату
    final start = next.toIso8601String();
    final end = next.add(const Duration(days: 1)).toIso8601String();

    // Обновляем все записи за эту дату (обычно одна)
    final update = await _client
        .from('deliveries')
        .update({
          'status': 'canceled',
          'notes': notes,
        })
        .eq('client_id', clientId)
        .gte('delivery_time', start)
        .lt('delivery_time', end);

    if (update.error != null) {
      throw Exception('Ошибка отмены: ${update.error!.message}');
    }
    return true;
  }
}

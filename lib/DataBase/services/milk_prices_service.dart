import 'package:molokosbor/DataBase/models/milk_prices.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MilkPricesService {
   final supabase = Supabase.instance.client;

  Future<List<MilkPrice>> getAllCollectors() async {
    try {
      final response = await supabase
          .from('milk_prices')
        .select();
      
      if (response == null || response is! List) {
        throw Exception("Некорректный ответ от сервера");
      }

      return response
          .map((json) => MilkPrice.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Ошибка при получении цены молока: $e');
      return [];
    }
  }
}
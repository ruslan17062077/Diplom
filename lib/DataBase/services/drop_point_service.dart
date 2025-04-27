import 'package:molokosbor/DataBase/models/drop_point.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DropPointService {
  final supabase = Supabase.instance.client;

  Future<void> updateDropPoint(DropPoint drop_point) async {
    await supabase
        .from('drop_point')
        .update(drop_point.toJson())
        .eq('id', drop_point.id!);
  }

 Future<DropPoint> addDropPoint(DropPoint dropPoint) async {
  // Вставляем и сразу просим вернуть полную строку
  final response = await supabase
      .from('drop_point')
      .insert({
        'adress': dropPoint.adress,
        'created_at': dropPoint.createdAt.toIso8601String(),
        'id_settlements': dropPoint.settlement!.id,
        'id_collector': dropPoint.profile!.id,
      })
      .select('*, id_collector(*), id_settlements(*)')        // спец. метод PostgREST: возвращает вставленные строки
      .single();       // берём первую (и единственную) запись
  return DropPoint.fromJson(response as Map<String, dynamic>);
}

}

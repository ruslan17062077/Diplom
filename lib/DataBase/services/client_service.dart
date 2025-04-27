import 'package:molokosbor/DataBase/models/deliveries.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientService {
  final supabase = Supabase.instance.client;

  Future<List<Profile>> getAllClients() async {
    try {
      final response = await supabase
          .from('profiles')
        .select('*, drop_point_id(*, id_collector(*), id_settlements(*))')
        .eq('role', 'client' );
      
      if (response == null || response is! List) {
        throw Exception("Некорректный ответ от сервера");
      }

      return response
          .map((json) => Profile.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Ошибка при получении клиентов: $e');
      return [];
    }
  }

  Future<void> updateClient(Profile profile) async {
    await supabase.from('profiles').update(profile.toJson()).eq('id', profile.id);
  }

  Future<String> deleteClient(Profile profile) async{
    return "Удалено";
  }
}
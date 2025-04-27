import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectorsService {
  final supabase = Supabase.instance.client;

  Future<List<Profile>> getAllCollectors() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('*, drop_point_id(*, id_collector(*), id_settlements(*))')
          .eq('role', 'collector');

      if (response == null || response is! List) {
        throw Exception("Некорректный ответ от сервера");
      }

      return response
          .map((json) => Profile.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Ошибка при получении сборщиков: $e');
      return [];
    }
  }

  Future<void> signUpCollector(Profile _profile, String password) async {
    final authResponse = await supabase.auth.admin.createUser(
      AdminUserAttributes(email: _profile.email, password: password)
    );
    final newProfile = Profile(
      id: authResponse.user!.id,
      first_name: _profile.first_name,
      name: _profile.name,
      last_name: _profile.last_name,
      email: _profile.email,
      role: 'collector',
      phone: _profile.phone,
      createdAt: DateTime.now(),
    );
    await supabase.from('profiles').insert({
    'id': newProfile.id,
    'first_name' : newProfile.first_name,
    'name': newProfile.name,
    'last_name': newProfile.last_name,
    'email': newProfile.email,
    'phone': newProfile.phone,
    'role': 'collector',
    'created_at': newProfile.createdAt.toIso8601String(),
    'drop_point_id': null, 
  });
  }
}

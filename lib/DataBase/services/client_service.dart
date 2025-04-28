import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    await supabase.from('profiles').update(profile.toJson()).eq('id', profile.id!);
  }

  Future<String> deleteClient(Profile profile) async{
    return "Удалено";
  }
  
  Future<Profile> signUpClient(Profile _profile, String password) async {
    final SupabaseClient _adminSupabase = SupabaseClient(
    'https://ijfnwqionlzjgqvwgbdd.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlqZm53cWlvbmx6amdxdndnYmRkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MzA3MTg1MywiZXhwIjoyMDU4NjQ3ODUzfQ.g8220Rr5nbxk-7D3ckfyNRr48dpv9Du29dSEs5YzdiE'
  );
    final authResponse = await _adminSupabase.auth.admin.createUser(
      AdminUserAttributes(email: _profile.email, password: password)
    );
    final newProfile = Profile(
      id: authResponse.user!.id,
      first_name: _profile.first_name,
      name: _profile.name,
      last_name: _profile.last_name,
      email: _profile.email,
      role: 'client',
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
    'role': 'client',
    'created_at': newProfile.createdAt.toIso8601String(),
    'drop_point_id': null, 
  });
  return newProfile;
  }
}
import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  Future<Profile> createAccountClient(Profile profile, String password) async {
    final supabase = Supabase.instance.client;

    // Регистрация пользователя
    final authResponse = await supabase.auth.signUp(
      email: profile.email,
      password: password,
    );

    final user = authResponse.user;
    if (user == null) {
      throw Exception('Не удалось создать пользователя');
    }

    final newProfile = Profile(
      id: user.id,
      first_name: profile.first_name,
      name: profile.name,
      last_name: profile.last_name,
      email: profile.email,
      phone: profile.phone,
      role: profile.role,
      createdAt: DateTime.now(),
      drop_point: profile.drop_point,
    );

    await supabase.from('profiles').insert({
      'id': newProfile.id,
      'first_name': newProfile.first_name,
      'name': newProfile.name,
      'last_name': newProfile.last_name,
      'email': newProfile.email,
      'phone': newProfile.phone,
      'role': 'client',
      'created_at': newProfile.createdAt.toIso8601String(),
      'drop_point_id': newProfile.drop_point!.id,
    });

    return newProfile;
  }
}

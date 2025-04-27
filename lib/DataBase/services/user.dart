import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  Future<Profile> getUser() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

   

    final response = await supabase
        .from('profiles')
        .select('*, drop_point_id(*, id_collector(*), id_settlements(*))')
        .eq('id', user!.id)
        .single();
    print(response);
   
    return Profile.fromJson(response);
  }
  
    Future<List<Profile>> getAllUsers() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('profiles')
        .select('* , drop_point(*)');
    print(response);
    final data = response as List<dynamic>;

    
    return data.map((item) => Profile.fromJson(item as Map<String, dynamic>)).toList();
    

  }
  

}
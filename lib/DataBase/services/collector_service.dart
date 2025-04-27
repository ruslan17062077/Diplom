import 'package:molokosbor/DataBase/models/drop_point.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectorService {
  final supabase = Supabase.instance.client;

  Future<List<DropPoint>> getAllDropPointCollector(String id) async {
    final response = await supabase
            .from('drop_point')
            .select('*, '
                'id_collector(*), '
                'id_settlements(*), '
                'profiles!profiles_drop_point_id_fkey('
                '*, '
                'deliveries!deliveries_client_id_fkey(*)'
                ')')
            .eq('id_collector', id) // уже был
            .eq('profiles.role', 'client') // фильтруем профиль по роли
        ;

    final data = response as List<dynamic>;
    return data
        .map((e) => DropPoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

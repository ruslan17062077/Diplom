import 'package:molokosbor/DataBase/models/settlements.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class SettlementService {
    final supabase = Supabase.instance.client;
    Future<List<Settlement>> getSettlementsOnce() async {
    final response = await supabase.from('settlements').select('*, drop_point(*, id_collector(*), id_settlements(*) )');
   
    return (response as List).map((json) => Settlement.fromJson(json)).toList();
  }
   Future<void> updateSettlement(Settlement settlements) async {
    final response = await supabase.from('settlements').update(settlements.toJson()).eq('id', settlements.id);
   
 
  }
  
}
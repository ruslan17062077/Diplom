import 'package:molokosbor/DataBase/models/profiles.dart';
import 'package:molokosbor/DataBase/models/settlements.dart';

class DropPoint {
  final int? id;
  final Settlement? settlement;
  final Profile? profile;
  final String adress;
  final DateTime createdAt;
  final List<Profile?>? clients;

  DropPoint({
     this.id,
     this.settlement,
    required this.profile,
    required this.adress,
    required this.createdAt,
    this.clients
  });

  factory DropPoint.fromJson(Map<String, dynamic> json) {
    return DropPoint(
      id: json['id'],
      adress: json['adress'],
      createdAt: DateTime.parse(json['created_at']),
      profile: Profile.fromJsonLight(json['id_collector']),
      settlement: Settlement.fromJsonLight(json['id_settlements']),
      clients: (json['profiles'] as List<dynamic>?)
        ?.map((e) => Profile.fromJsonLight(e as Map<String, dynamic>))
        .toList()
        .cast<Profile>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adress': adress,
      'created_at': createdAt.toIso8601String(),
      'id_settlements': settlement!.id,
      'id_collector': profile!.id,
    };
  }
}

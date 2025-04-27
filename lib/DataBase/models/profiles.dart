

import 'package:molokosbor/DataBase/models/deliveries.dart';
import 'package:molokosbor/DataBase/models/drop_point.dart';
import 'package:molokosbor/DataBase/models/settlements.dart';

/// Модель профиля пользователя (таблица profiles)
class Profile {
  final String id;
  final String? first_name;
  final String name;
  final String? last_name;
  final String email;
  final String? phone;
  final String role;
  final DateTime createdAt;
  final DropPoint? drop_point;
  final List<Delivery?>? delivery;
  Profile({
    required this.id,
    this.first_name,
    required this.name,
    this.last_name,
    required this.email,
    this.phone,
    required this.role,
    required this.createdAt,
    this.drop_point,
    this.delivery
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      first_name: json['first_name'],
      name: json['name'],
      last_name: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
      drop_point: json['drop_point_id'] != null
          ? DropPoint.fromJson(json['drop_point_id'])
          : null,
          delivery: (json['deliveries'] as List<dynamic>?)
        ?.map((e) => Delivery.fromJson(e as Map<String, dynamic>))
        .toList()
        .cast<Delivery>(),
    );
  }
factory Profile.fromJsonLight(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      first_name: json['first_name'],
      name: json['name'],
      last_name: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
         delivery: (json['deliveries'] as List<dynamic>?)
        ?.map((e) => Delivery.fromJson(e as Map<String, dynamic>))
        .toList()
        .cast<Delivery>(),
    );
      
}
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': first_name,
      'name': name,
      'last_name': last_name,
      'email': email,
      'phone': phone,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'drop_point_id': drop_point?.id,
    };
  }
}
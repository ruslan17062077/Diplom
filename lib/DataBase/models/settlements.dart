import 'package:molokosbor/DataBase/models/drop_point.dart';

class Settlement {
  final int id;
  final String name;
  final String? region;
  final String? coords;
  final DateTime createdAt;
  final List<DropPoint>? dropPoint;

  Settlement({
    required this.id,
    required this.name,
    this.region,
    this.coords,
    required this.createdAt,
    this.dropPoint,
  });

  /// Полный JSON с точками
  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      id: json['id'],
      name: json['name'],
      region: json['region'],
      coords: json['coords'],
      createdAt: DateTime.parse(json['created_at']),
      dropPoint: (json['drop_point'] as List<dynamic>?)
          ?.map((e) => DropPoint.fromJson(e))
          .toList(),
    );
  }

   factory Settlement.fromJsonLight(Map<String, dynamic> json) {
    return Settlement(
      id: json['id'],
      name: json['name'],
      region: json['region'],
      coords: json['coords'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'coords': coords,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

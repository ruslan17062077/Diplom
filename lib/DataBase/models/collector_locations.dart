import 'package:molokosbor/DataBase/models/profiles.dart';

/// Модель истории геолокации сборщика (таблица collector_locations)
class CollectorLocation {
  final int id;
  final Profile collectorId;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;

  CollectorLocation({
    required this.id,
    required this.collectorId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
  });

  factory CollectorLocation.fromJson(Map<String, dynamic> json) {
    return CollectorLocation(
      id: json['id'] as int,
      collectorId: json[''] as Profile,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collector_id': collectorId,
      'latitude': latitude,
      'longitude': longitude,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }
}
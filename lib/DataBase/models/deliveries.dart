import 'package:supabase_flutter/supabase_flutter.dart';

/// Модель сдачи молока (таблица deliveries)
class Delivery {
  final int? id;
  final String clientId;
  final String? collectorId;
  final DateTime deliveryTime;
  final num volume;

  final String status;
  final String? notes;
  final DateTime createdAt;

  Delivery({
     this.id,
    required this.clientId,
    this.collectorId,
    required this.deliveryTime,
    required this.volume,

    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as int,
      clientId: json['client_id'] as String,
      collectorId: json['collector_id'] as String?,
      deliveryTime: DateTime.parse(json['delivery_time'] as String),
      volume: json['volume'] as num,

      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
  final map = <String, dynamic>{
    'client_id': clientId,
    'collector_id': collectorId,
    'delivery_time': deliveryTime.toIso8601String(),
    'volume': volume,
    'status': status,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };
  if (id != null) {
    map['id'] = id;
  }
  return map;
}



}
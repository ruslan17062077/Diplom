/// Модель заявки о поломках (таблица breakdowns)
class Breakdown {
  final int id;
  final int? vehicleId;
  final String? collectorId;
  final String description;
  final DateTime dateReported;
  final String status;
  final String? resolution;
  final DateTime createdAt;

  Breakdown({
    required this.id,
    this.vehicleId,
    this.collectorId,
    required this.description,
    required this.dateReported,
    required this.status,
    this.resolution,
    required this.createdAt,
  });

  factory Breakdown.fromJson(Map<String, dynamic> json) {
    return Breakdown(
      id: json['id'] as int,
      vehicleId: json['vehicle_id'] as int?,
      collectorId: json['collector_id'] as String?,
      description: json['description'] as String,
      dateReported: DateTime.parse(json['date_reported'] as String),
      status: json['status'] as String,
      resolution: json['resolution'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'collector_id': collectorId,
      'description': description,
      'date_reported': dateReported.toIso8601String(),
      'status': status,
      'resolution': resolution,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
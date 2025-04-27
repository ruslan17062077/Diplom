/// Модель транспорта (таблица vehicles)
class Vehicle {
  final int id;
  final String numberPlate;
  final String? model;
  final num? capacity;
  final String? assignedTo; // id профиля (UUID) сборщика
  final DateTime createdAt;

  Vehicle({
    required this.id,
    required this.numberPlate,
    this.model,
    this.capacity,
    this.assignedTo,
    required this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int,
      numberPlate: json['number_plate'] as String,
      model: json['model'] as String?,
      capacity: json['capacity'] as num?,
      assignedTo: json['assigned_to'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number_plate': numberPlate,
      'model': model,
      'capacity': capacity,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
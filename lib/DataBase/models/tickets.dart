/// Универсальная модель заявки (таблица tickets)
class Ticket {
  final int id;
  final String? authorId;
  final String type;
  final String? description;
  final String status;
  final String? assigneeId;
  final int? vehicleId;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  Ticket({
    required this.id,
    this.authorId,
    required this.type,
    this.description,
    required this.status,
    this.assigneeId,
    this.vehicleId,
    required this.createdAt,
    this.resolvedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      authorId: json['author_id'] as String?,
      type: json['type'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      assigneeId: json['assignee_id'] as String?,
      vehicleId: json['vehicle_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'type': type,
      'description': description,
      'status': status,
      'assignee_id': assigneeId,
      'vehicle_id': vehicleId,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }
}
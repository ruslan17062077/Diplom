/// Модель заявки на внеплановые траты (таблица expenses)
class Expense {
  final int id;
  final int? vehicleId;
  final String? collectorId;
  final num amount;
  final String? description;
  final DateTime expenseTime;
  final String status;
  final DateTime createdAt;

  Expense({
    required this.id,
    this.vehicleId,
    this.collectorId,
    required this.amount,
    this.description,
    required this.expenseTime,
    required this.status,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      vehicleId: json['vehicle_id'] as int?,
      collectorId: json['collector_id'] as String?,
      amount: json['amount'] as num,
      description: json['description'] as String?,
      expenseTime: DateTime.parse(json['expense_time'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'collector_id': collectorId,
      'amount': amount,
      'description': description,
      'expense_time': expenseTime.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

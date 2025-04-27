/// Модель истории цен на молоко (таблица milk_prices)
class MilkPrice {
  final int id;
  final num price;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  MilkPrice({
    required this.id,
    required this.price,
    required this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory MilkPrice.fromJson(Map<String, dynamic> json) {
    return MilkPrice(
      id: json['id'] as int,
      price: json['price'] as num,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Discount {
  final String id;
  final int percentage;
  final double amount;

  Discount({
    required this.id,
    required this.percentage,
    required this.amount,
  });

  // Add copyWith method for Discount
  Discount copyWith({
    String? id,
    int? percentage,
    double? amount,
  }) {
    return Discount(
      id: id ?? this.id,
      percentage: percentage ?? this.percentage,
      amount: amount ?? this.amount,
    );
  }
}
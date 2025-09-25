import 'package:my_pos/models/food_model.dart';
import 'package:my_pos/models/discount_model.dart';

// models/ticket.dart
class Ticket {
  final String id;
  final String name;
  final List<Food> items;
  final DateTime createdAt;
  final String paymentMethod;
  final List<Discount> discounts;

  @override
  String toString() {
    return 'Ticket(name: $name, id: $id, items: ${items.length}, totalItems: ${items.fold(0, (sum, item) => sum + item.quantity)}, createdAt: $createdAt, paymentMethod: $paymentMethod)';
  }

  Ticket({
    required this.id,
    required this.name,
    required this.items,
    required this.paymentMethod,
    DateTime? createdAt,
    List<Discount>? discounts,
  }) : createdAt = createdAt ?? DateTime.now(), discounts = discounts ?? [];

  double get totalAmount {
    final subtotal = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final discountTotal = discounts.fold(0.0, (sum, discount) => sum + discount.amount);
    return subtotal - discountTotal;
  }

  Ticket copyWith({
    String? id,
    String? name,
    List<Food>? items,
    DateTime? createdAt,
    String? paymentMethod,
    List<Discount>? discounts,
  }) {
    return Ticket(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      discounts: discounts ?? this.discounts,
    );
  }

  // Convert Ticket to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'paymentMethod': paymentMethod,
      'discounts': discounts.map((discount) => discount.toMap()).toList(), // Add discounts
    };
  }

  // Create Ticket from Map - FIXED VERSION
  static Ticket fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      items: List<Food>.from(
        (map['items'] as List<dynamic>).map(
              (item) => Food.fromMap(item as Map<String, dynamic>),
        ),
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      discounts: map['discounts'] != null
          ? List<Discount>.from(
        (map['discounts'] as List<dynamic>).map(
              (discount) => Discount.fromMap(discount as Map<String, dynamic>),
        ),
      )
          : [], // Handle discounts
    );
  }

  // Add toJson method for JSON serialization
  Map<String, dynamic> toJson() {
    return toMap();
  }

  // Add fromJson method for completeness
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return fromMap(json);
  }
}
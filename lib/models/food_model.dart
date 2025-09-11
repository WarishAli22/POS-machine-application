// models/food_item.dart
class Food {
  final String id;
  final String imageUrl;
  final String title;
  final double price;
  final int quantity;

  Food({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.quantity = 1
  });

  Food copyWith({
    String? id,
    String? imageUrl,
    String? name,
    double? price,
    int? quantity,
  }) {
    return Food(
      id : id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  // Convert FoodItem to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'price': price,
      'quantity': quantity,
    };
  }

  // Create FoodItem from Map
  static Food fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? '',
      price: (map['price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toInt(),
    );
  }
}

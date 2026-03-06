import 'cart_item.dart';

class Order {
  const Order({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.isRated,
    required this.total,
  });

  final String id;
  final String restaurantId;
  final String restaurantName;
  final String status;
  final List<CartItem> items;
  final DateTime createdAt;
  final bool isRated;
  final double total;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      restaurantName: json['restaurantName'] as String,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRated: json['isRated'] as bool? ?? false,
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'status': status,
      'items': items.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isRated': isRated,
      'total': total,
    };
  }

  Order copyWith({
    bool? isRated,
    String? status,
  }) {
    return Order(
      id: id,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      status: status ?? this.status,
      items: items,
      createdAt: createdAt,
      isRated: isRated ?? this.isRated,
      total: total,
    );
  }
}

import '../../common/domain/entities/cart_item.dart';

class CartState {
  const CartState({
    this.items = const [],
    this.restaurantId,
    this.restaurantName,
  });

  final List<CartItem> items;
  final String? restaurantId;
  final String? restaurantName;

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.lineTotal);
  double get tax => subtotal * 0.08;
  double get total => subtotal + tax;
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItem>? items,
    String? restaurantId,
    String? restaurantName,
    bool resetRestaurant = false,
  }) {
    return CartState(
      items: items ?? this.items,
      restaurantId:
          resetRestaurant ? null : (restaurantId ?? this.restaurantId),
      restaurantName:
          resetRestaurant ? null : (restaurantName ?? this.restaurantName),
    );
  }

  factory CartState.fromJson(Map<String, dynamic> json) {
    return CartState(
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      restaurantId: json['restaurantId'] as String?,
      restaurantName: json['restaurantName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
    };
  }
}

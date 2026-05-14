import 'add_on.dart';
import 'menu_item.dart';

class CartItem {
  const CartItem({
    required this.item,
    required this.quantity,
    this.selectedAddOns = const [],
  });

  final MenuItem item;
  final int quantity;
  final List<AddOnOption> selectedAddOns;

  /// Unique key combining item id + sorted add-on ids.
  /// Two cart entries with identical item and add-ons share the same key.
  String get cartKey {
    final ids = selectedAddOns.map((a) => a.id).toList()..sort();
    return '${item.id}:${ids.join(',')}';
  }

  double get addOnsExtra =>
      selectedAddOns.fold(0.0, (sum, ao) => sum + ao.extraCost);

  double get unitPrice => item.price + addOnsExtra;

  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({
    MenuItem? item,
    int? quantity,
    List<AddOnOption>? selectedAddOns,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      selectedAddOns: selectedAddOns ?? this.selectedAddOns,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      item: MenuItem.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      selectedAddOns: (json['selectedAddOns'] as List<dynamic>? ?? [])
          .map((e) => AddOnOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item.toJson(),
      'quantity': quantity,
      'selectedAddOns': selectedAddOns.map((e) => e.toJson()).toList(),
    };
  }
}

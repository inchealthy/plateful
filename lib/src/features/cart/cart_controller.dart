import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../common/domain/entities/cart_item.dart';
import 'cart_state.dart';

class CartNotifier extends Notifier<CartState> {
  static const _boxName = 'cart';
  static const _cartKey = 'current_cart';

  late Box<String> _box;

  @override
  CartState build() {
    _box = Hive.box<String>(_boxName);
    final saved = _box.get(_cartKey);
    if (saved == null) {
      return const CartState();
    }

    try {
      return CartState.fromJson(jsonDecode(saved) as Map<String, dynamic>);
    } catch (_) {
      return const CartState();
    }
  }

  bool hasConflictWithRestaurant(String restaurantId) {
    return state.items.isNotEmpty &&
        state.restaurantId != null &&
        state.restaurantId != restaurantId;
  }

  void addItem(CartItem newItem, {required String restaurantName}) {
    final existingIndex =
        state.items.indexWhere((i) => i.cartKey == newItem.cartKey);

    late final List<CartItem> updatedItems;
    if (existingIndex >= 0) {
      updatedItems = [...state.items];
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] =
          existing.copyWith(quantity: existing.quantity + newItem.quantity);
    } else {
      updatedItems = [...state.items, newItem];
    }

    _updateState(
      state.copyWith(
        items: updatedItems,
        restaurantId: newItem.item.restaurantId,
        restaurantName: restaurantName,
      ),
    );
  }

  void clearAndAdd(CartItem newItem, {required String restaurantName}) {
    _updateState(
      CartState(
        items: [newItem],
        restaurantId: newItem.item.restaurantId,
        restaurantName: restaurantName,
      ),
    );
  }

  /// Removes the specific cart entry identified by [cartKey].
  void removeItem(String cartKey) {
    final updatedItems =
        state.items.where((i) => i.cartKey != cartKey).toList();
    if (updatedItems.isEmpty) {
      _updateState(const CartState());
      return;
    }
    _updateState(state.copyWith(items: updatedItems));
  }

  /// Updates quantity of the specific cart entry identified by [cartKey].
  void updateQuantity(String cartKey, int quantity) {
    if (quantity <= 0) {
      removeItem(cartKey);
      return;
    }

    final updatedItems = state.items
        .map((i) => i.cartKey == cartKey ? i.copyWith(quantity: quantity) : i)
        .toList();

    _updateState(state.copyWith(items: updatedItems));
  }

  /// Used by the menu list's quick-decrement button, which only knows item.id.
  /// Decrements the first cart entry that matches [menuItemId].
  void decrementFirstByItemId(String menuItemId) {
    final idx = state.items.indexWhere((i) => i.item.id == menuItemId);
    if (idx < 0) return;
    final entry = state.items[idx];
    updateQuantity(entry.cartKey, entry.quantity - 1);
  }

  void clearCart() {
    _updateState(const CartState());
  }

  void _updateState(CartState newState) {
    state = newState;
    _box.put(_cartKey, jsonEncode(newState.toJson()));
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

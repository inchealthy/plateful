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
        state.items.indexWhere((item) => item.item.id == newItem.item.id);

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

  void removeItem(String menuItemId) {
    final updatedItems =
        state.items.where((item) => item.item.id != menuItemId).toList();
    if (updatedItems.isEmpty) {
      _updateState(const CartState());
      return;
    }

    _updateState(state.copyWith(items: updatedItems));
  }

  void updateQuantity(String menuItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(menuItemId);
      return;
    }

    final updatedItems = state.items
        .map(
          (item) => item.item.id == menuItemId
              ? item.copyWith(quantity: quantity)
              : item,
        )
        .toList();

    _updateState(state.copyWith(items: updatedItems));
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

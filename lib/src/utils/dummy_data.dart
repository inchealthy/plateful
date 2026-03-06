import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../common/domain/entities/cart_item.dart';
import '../common/domain/entities/menu_item.dart';
import '../common/domain/entities/order.dart';

class DummyData {
  const DummyData._();

  static const _ordersKey = 'orders_list';
  static const _isSeededKey = 'is_seeded';

  static Future<void> seedIfNeeded(
    Box<String> ordersBox,
    Box<bool> metaBox,
  ) async {
    if (metaBox.get(_isSeededKey) == true) {
      return;
    }

    final seededOrders = [
      Order(
        id: 'seed_001',
        restaurantId: 'r1',
        restaurantName: 'Main Campus Cafeteria',
        items: [
          CartItem(
            item: _mockItem(
              id: 'm1',
              restaurantId: 'r1',
              name: 'Canyon Classic Burger',
              emoji: '🍔',
              category: 'Lunch',
              price: 8.50,
            ),
            quantity: 1,
          ),
          CartItem(
            item: _mockItem(
              id: 'm2',
              restaurantId: 'r1',
              name: 'Mediterranean Bowl',
              emoji: '🥙',
              category: 'Lunch',
              price: 9.25,
            ),
            quantity: 2,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'completed',
        isRated: false,
        total: _withTax(27.00),
      ),
      Order(
        id: 'seed_002',
        restaurantId: 'r3',
        restaurantName: 'Riverside Coffee & Bakery',
        items: [
          CartItem(
            item: _mockItem(
              id: 'm14',
              restaurantId: 'r3',
              name: 'Caramel Latte',
              emoji: '☕',
              category: 'Beverages',
              price: 4.50,
            ),
            quantity: 2,
          ),
          CartItem(
            item: _mockItem(
              id: 'm16',
              restaurantId: 'r3',
              name: 'Blueberry Muffin',
              emoji: '🫐',
              category: 'Snacks',
              price: 3.50,
            ),
            quantity: 1,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        status: 'completed',
        isRated: false,
        total: _withTax(12.50),
      ),
      Order(
        id: 'seed_003',
        restaurantId: 'r4',
        restaurantName: 'Student Union Grill',
        items: [
          CartItem(
            item: _mockItem(
              id: 'm19',
              restaurantId: 'r4',
              name: 'Smash Burger',
              emoji: '🍔',
              category: 'Lunch',
              price: 9.50,
            ),
            quantity: 1,
          ),
          CartItem(
            item: _mockItem(
              id: 'm20',
              restaurantId: 'r4',
              name: 'Loaded Fries',
              emoji: '🍟',
              category: 'Snacks',
              price: 5.00,
            ),
            quantity: 1,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        status: 'completed',
        isRated: false,
        total: _withTax(14.50),
      ),
    ];

    final payload =
        jsonEncode(seededOrders.map((order) => order.toJson()).toList());
    await ordersBox.put(_ordersKey, payload);
    await metaBox.put(_isSeededKey, true);
  }

  static MenuItem _mockItem({
    required String id,
    required String restaurantId,
    required String name,
    required String emoji,
    required String category,
    required double price,
  }) {
    return MenuItem(
      id: id,
      restaurantId: restaurantId,
      name: name,
      description: '',
      emoji: emoji,
      category: category,
      price: price,
      calories: 0,
      carbs: 0,
      protein: 0,
      fat: 0,
      allergens: const [],
      dietaryTags: const [],
    );
  }

  static double _withTax(double subtotal) {
    final total = subtotal * 1.08;
    return double.parse(total.toStringAsFixed(2));
  }
}

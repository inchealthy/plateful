import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:plateful/src/common/domain/entities/cart_item.dart';
import 'package:plateful/src/common/domain/entities/menu_item.dart';
import 'package:plateful/src/common/domain/entities/order.dart';
import 'package:plateful/src/features/orders/orders_controller.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearAll);

  MenuItem menuItem(String id) {
    return MenuItem(
      id: id,
      restaurantId: 'r1',
      name: id,
      description: '',
      emoji: '🍽️',
      category: 'Lunch',
      price: 10,
      calories: 0,
      carbs: 0,
      protein: 0,
      fat: 0,
      allergens: const [],
      dietaryTags: const [],
    );
  }

  Order order({
    required String id,
    required DateTime createdAt,
    String status = 'completed',
    bool isRated = false,
  }) {
    return Order(
      id: id,
      restaurantId: 'r1',
      restaurantName: 'Main Campus Cafeteria',
      status: status,
      items: [CartItem(item: menuItem('m1'), quantity: 1)],
      createdAt: createdAt,
      isRated: isRated,
      total: 10.8,
    );
  }

  test('loads and sorts orders newest first', () async {
    final older = order(id: 'older', createdAt: DateTime(2026, 1, 1, 10));
    final newer = order(id: 'newer', createdAt: DateTime(2026, 1, 1, 12));
    await Hive.box<String>('orders').put(
      'orders_list',
      jsonEncode([older.toJson(), newer.toJson()]),
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(ordersProvider);
    expect(state.orders.length, 2);
    expect(state.orders.first.id, 'newer');
  });

  test('addOrder inserts at top and persists', () async {
    final initial = order(id: 'initial', createdAt: DateTime(2026, 1, 1, 10));
    await Hive.box<String>('orders').put(
      'orders_list',
      jsonEncode([initial.toJson()]),
    );

    final container = ProviderContainer();

    final notifier = container.read(ordersProvider.notifier);
    final added = order(id: 'added', createdAt: DateTime(2026, 1, 1, 13));
    notifier.addOrder(added);

    final state = container.read(ordersProvider);
    expect(state.orders.first.id, 'added');

    container.dispose();

    final rehydrated = ProviderContainer();
    addTearDown(rehydrated.dispose);
    expect(rehydrated.read(ordersProvider).orders.first.id, 'added');
  });

  test('markAsRated updates state and persists', () async {
    final existing = order(
      id: 'rate_me',
      createdAt: DateTime(2026, 1, 1, 10),
      isRated: false,
    );
    await Hive.box<String>('orders').put(
      'orders_list',
      jsonEncode([existing.toJson()]),
    );

    final container = ProviderContainer();

    container.read(ordersProvider.notifier).markAsRated('rate_me');
    expect(container.read(ordersProvider).orders.first.isRated, isTrue);

    container.dispose();

    final rehydrated = ProviderContainer();
    addTearDown(rehydrated.dispose);
    expect(rehydrated.read(ordersProvider).orders.first.isRated, isTrue);
  });

  test('simulateOrderProgress updates order status over time', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final created = order(
      id: 'sim_1',
      createdAt: DateTime(2026, 1, 1, 10),
      status: 'preparing',
    );
    container.read(ordersProvider.notifier).addOrder(created);

    final future =
        container.read(ordersProvider.notifier).simulateOrderProgress(
              'sim_1',
              readyDelay: const Duration(milliseconds: 20),
              completedDelay: const Duration(milliseconds: 20),
            );

    await Future<void>.delayed(const Duration(milliseconds: 25));
    expect(container.read(ordersProvider).orders.first.status, 'ready');

    await future;
    expect(container.read(ordersProvider).orders.first.status, 'completed');
  });
}

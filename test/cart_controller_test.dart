import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plateful/src/common/domain/entities/cart_item.dart';
import 'package:plateful/src/common/domain/entities/menu_item.dart';
import 'package:plateful/src/features/cart/cart_controller.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearCart);

  MenuItem menuItem({
    required String id,
    required String restaurantId,
    double price = 5,
  }) {
    return MenuItem(
      id: id,
      restaurantId: restaurantId,
      name: id,
      description: 'desc',
      emoji: '🍽️',
      category: 'Lunch',
      price: price,
      calories: 100,
      carbs: 10,
      protein: 5,
      fat: 2,
      allergens: const [],
      dietaryTags: const [],
    );
  }

  test('add/merge computes totals', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(cartProvider.notifier);
    final item = menuItem(id: 'm1', restaurantId: 'r1', price: 10);

    notifier.addItem(CartItem(item: item, quantity: 1), restaurantName: 'R1');
    notifier.addItem(CartItem(item: item, quantity: 2), restaurantName: 'R1');

    final state = container.read(cartProvider);
    expect(state.items.length, 1);
    expect(state.items.first.quantity, 3);
    expect(state.totalItems, 3);
    expect(state.subtotal, 30);
    expect(state.tax, 2.4);
    expect(state.total, 32.4);
  });

  test('restaurant conflict check + clearAndAdd replace works', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(cartProvider.notifier);
    notifier.addItem(
      CartItem(item: menuItem(id: 'm1', restaurantId: 'r1'), quantity: 1),
      restaurantName: 'R1',
    );

    expect(notifier.hasConflictWithRestaurant('r1'), false);
    expect(notifier.hasConflictWithRestaurant('r2'), true);

    notifier.clearAndAdd(
      CartItem(item: menuItem(id: 'm2', restaurantId: 'r2'), quantity: 2),
      restaurantName: 'R2',
    );

    final state = container.read(cartProvider);
    expect(state.items.length, 1);
    expect(state.items.first.item.id, 'm2');
    expect(state.restaurantId, 'r2');
  });

  test('quantity update and remove works', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(cartProvider.notifier);
    notifier.addItem(
      CartItem(item: menuItem(id: 'm1', restaurantId: 'r1'), quantity: 1),
      restaurantName: 'R1',
    );

    notifier.updateQuantity('m1', 4);
    expect(container.read(cartProvider).items.first.quantity, 4);

    notifier.removeItem('m1');
    final state = container.read(cartProvider);
    expect(state.items, isEmpty);
    expect(state.restaurantId, isNull);
  });

  test('state persists and rehydrates from Hive', () {
    final containerA = ProviderContainer();
    final notifier = containerA.read(cartProvider.notifier);

    notifier.addItem(
      CartItem(item: menuItem(id: 'm1', restaurantId: 'r1'), quantity: 2),
      restaurantName: 'R1',
    );
    containerA.dispose();

    final containerB = ProviderContainer();
    addTearDown(containerB.dispose);

    final state = containerB.read(cartProvider);
    expect(state.items.length, 1);
    expect(state.items.first.quantity, 2);
    expect(state.restaurantName, 'R1');
  });
}

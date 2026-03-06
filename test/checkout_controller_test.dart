import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plateful/src/common/domain/entities/cart_item.dart';
import 'package:plateful/src/common/domain/entities/menu_item.dart';
import 'package:plateful/src/features/cart/cart_controller.dart';
import 'package:plateful/src/features/checkout/checkout_controller.dart';
import 'package:plateful/src/features/orders/orders_controller.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearAll);

  const item = MenuItem(
    id: 'm1',
    restaurantId: 'r1',
    name: 'Canyon Classic Burger',
    description: '',
    emoji: '🍔',
    category: 'Lunch',
    price: 8.5,
    calories: 0,
    carbs: 0,
    protein: 0,
    fat: 0,
    allergens: [],
    dietaryTags: [],
  );

  test('placeOrder sets loading then creates order and clears cart', () async {
    final container = ProviderContainer(
      overrides: [
        orderProgressSimulationEnabledProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);

    container.read(cartProvider.notifier).addItem(
          const CartItem(item: item, quantity: 2),
          restaurantName: 'Main Campus Cafeteria',
        );

    final controller = container.read(checkoutProvider.notifier);
    final future = controller.placeOrder();

    expect(container.read(checkoutProvider).isLoading, isTrue);

    await future;

    final checkout = container.read(checkoutProvider);
    final cart = container.read(cartProvider);
    final orders = container.read(ordersProvider);

    expect(checkout.isLoading, isFalse);
    expect(checkout.orderPlaced, isTrue);
    expect(cart.items, isEmpty);
    expect(orders.orders, isNotEmpty);
    expect(orders.orders.first.status, 'preparing');
    expect(orders.orders.first.total, closeTo(18.36, 0.0001));
  });
}

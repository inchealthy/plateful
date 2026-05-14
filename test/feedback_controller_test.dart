import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:plateful/src/common/domain/entities/cart_item.dart';
import 'package:plateful/src/common/domain/entities/menu_item.dart';
import 'package:plateful/src/common/domain/entities/order.dart';
import 'package:plateful/src/features/feedback/feedback_controller.dart';
import 'package:plateful/src/features/feedback/feedback_state.dart';
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

  test('submit stores feedback and marks order rated', () async {
    final order = Order(
      id: 'order_1',
      restaurantId: 'r1',
      restaurantName: 'Main Campus Cafeteria',
      status: 'completed',
      items: const [CartItem(item: item, quantity: 1)],
      createdAt: DateTime(2026, 1, 1, 10),
      isRated: false,
      total: 9.18,
    );

    await Hive.box<String>('orders').put(
      'orders_list',
      jsonEncode([order.toJson()]),
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(ordersProvider);

    final provider = feedbackProvider(order.id);
    final notifier = container.read(provider.notifier);
    await Future<void>.delayed(Duration.zero);

    notifier.setRating(FeedbackDimension.overall, 5);
    notifier.setRating(FeedbackDimension.food, 4);
    notifier.setRating(FeedbackDimension.service, 4);
    notifier.setRating(FeedbackDimension.recommend, 5);
    notifier.setComment('great');

    await notifier.submit();

    final state = container.read(provider);
    expect(state.submitted, isTrue);

    final feedbackRaw = Hive.box<String>('feedbacks').get('feedbacks_list');
    expect(feedbackRaw, isNotNull);

    final feedbackList = jsonDecode(feedbackRaw!) as List<dynamic>;
    expect(feedbackList.length, 1);
    expect(feedbackList.first['orderId'], 'order_1');

    final updatedOrder = container
        .read(ordersProvider)
        .orders
        .firstWhere((value) => value.id == 'order_1');
    expect(updatedOrder.isRated, isTrue);
  });
}

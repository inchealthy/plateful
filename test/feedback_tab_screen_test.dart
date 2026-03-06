import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:plateful/src/app/themes/app_theme.dart';
import 'package:plateful/src/common/domain/entities/cart_item.dart';
import 'package:plateful/src/common/domain/entities/menu_item.dart';
import 'package:plateful/src/common/domain/entities/order.dart';
import 'package:plateful/src/features/feedback/feedback_tab_screen.dart';

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

  Order order({required String id, required bool isRated}) {
    return Order(
      id: id,
      restaurantId: 'r1',
      restaurantName: 'Main Campus Cafeteria',
      status: 'completed',
      items: const [CartItem(item: item, quantity: 1)],
      createdAt: DateTime(2026, 1, 1, 10),
      isRated: isRated,
      total: 9.18,
    );
  }

  Future<void> seedOrders(WidgetTester tester, List<Order> orders) async {
    await tester.runAsync(() async {
      await Hive.box<String>('orders').put(
        'orders_list',
        jsonEncode(orders.map((value) => value.toJson()).toList()),
      );
    });
  }

  Future<void> pumpFeedbackTabApp(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            theme: AppTheme.light(),
            home: const FeedbackTabScreen(),
          ),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets('shows unrated orders list', (tester) async {
    await seedOrders(tester, [
      order(id: 'order_unrated', isRated: false),
      order(id: 'order_rated', isRated: true),
    ]);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await pumpFeedbackTabApp(tester, container);

    expect(
      find.byKey(const Key('feedback-unrated-order_unrated')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('feedback-unrated-order_rated')), findsNothing);
  });

  testWidgets('shows all-caught-up empty state when no unrated orders',
      (tester) async {
    await seedOrders(tester, [
      order(id: 'order_rated', isRated: true),
    ]);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await pumpFeedbackTabApp(tester, container);

    expect(find.text('All caught up!'), findsOneWidget);
    expect(find.text('No pending reviews'), findsOneWidget);
  });
}

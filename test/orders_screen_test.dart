import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:plateful/src/app/themes/app_theme.dart';
import 'package:plateful/src/common/domain/entities/cart_item.dart';
import 'package:plateful/src/common/domain/entities/menu_item.dart';
import 'package:plateful/src/common/domain/entities/order.dart';
import 'package:plateful/src/features/orders/orders_screen.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearAll);

  MenuItem menuItem(String id, String name, String emoji, double price) {
    return MenuItem(
      id: id,
      restaurantId: 'r1',
      name: name,
      description: '',
      emoji: emoji,
      category: 'Lunch',
      price: price,
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
    required String restaurantId,
    required String restaurantName,
    required DateTime createdAt,
    required String status,
    required bool isRated,
  }) {
    return Order(
      id: id,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      status: status,
      items: [
        CartItem(
            item: menuItem('m1', 'Canyon Classic Burger', '🍔', 8.5),
            quantity: 1),
        CartItem(
            item: menuItem('m2', 'Mediterranean Bowl', '🥙', 9.25),
            quantity: 1),
      ],
      createdAt: createdAt,
      isRated: isRated,
      total: 19.17,
    );
  }

  Future<void> seedOrders(WidgetTester tester, List<Order> orders) async {
    await tester.runAsync(() async {
      final payload = jsonEncode(orders.map((e) => e.toJson()).toList());
      await Hive.box<String>('orders').put('orders_list', payload);
    });
  }

  Future<void> pumpOrdersApp(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    final router = GoRouter(
      initialLocation: '/shell/orders',
      routes: [
        GoRoute(
          path: '/shell/orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/feedback/:orderId',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId'];
            return Scaffold(
              appBar: AppBar(title: const Text('Feedback')),
              body: Center(child: Text('Feedback $orderId')),
            );
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: router,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('orders list sorted newest first and detail sheet shows items', (
    tester,
  ) async {
    final oldOrder = order(
      id: 'old_123456',
      restaurantId: 'r1',
      restaurantName: 'Main Campus Cafeteria',
      createdAt: DateTime(2026, 1, 1, 10),
      status: 'completed',
      isRated: false,
    );
    final newOrder = order(
      id: 'new_654321',
      restaurantId: 'r3',
      restaurantName: 'Riverside Coffee & Bakery',
      createdAt: DateTime(2026, 1, 1, 12),
      status: 'completed',
      isRated: false,
    );
    await seedOrders(tester, [oldOrder, newOrder]);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await pumpOrdersApp(tester, container);

    final newDy =
        tester.getTopLeft(find.byKey(const Key('order-card-new_654321'))).dy;
    final oldDy =
        tester.getTopLeft(find.byKey(const Key('order-card-old_123456'))).dy;
    expect(newDy, lessThan(oldDy));

    await tester.tap(find.byKey(const Key('order-card-new_654321')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Canyon Classic Burger'), findsOneWidget);
    expect(find.text('Mediterranean Bowl'), findsOneWidget);
    expect(find.byKey(const Key('leave-feedback-new_654321')), findsOneWidget);
  });

  testWidgets('leave feedback CTA only on completed and unrated orders', (
    tester,
  ) async {
    final eligible = order(
      id: 'eligible_001',
      restaurantId: 'r1',
      restaurantName: 'Main Campus Cafeteria',
      createdAt: DateTime(2026, 1, 1, 12),
      status: 'completed',
      isRated: false,
    );
    final rated = order(
      id: 'rated_001',
      restaurantId: 'r1',
      restaurantName: 'Main Campus Cafeteria',
      createdAt: DateTime(2026, 1, 1, 11),
      status: 'completed',
      isRated: true,
    );
    final preparing = order(
      id: 'prep_001',
      restaurantId: 'r1',
      restaurantName: 'Main Campus Cafeteria',
      createdAt: DateTime(2026, 1, 1, 10),
      status: 'preparing',
      isRated: false,
    );
    await seedOrders(tester, [eligible, rated, preparing]);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await pumpOrdersApp(tester, container);

    await tester.tap(
      find.byKey(const Key('order-card-eligible_001')).hitTestable(),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
        find.byKey(const Key('leave-feedback-eligible_001')), findsOneWidget);

    await tester.tap(find.byKey(const Key('leave-feedback-eligible_001')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Feedback eligible_001'), findsOneWidget);

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.ensureVisible(find.byKey(const Key('order-card-rated_001')));
    await tester
        .tap(find.byKey(const Key('order-card-rated_001')).hitTestable());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('leave-feedback-rated_001')), findsNothing);
    await tester.tapAt(const Offset(8, 8));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.byKey(const Key('order-card-prep_001')));
    await tester
        .tap(find.byKey(const Key('order-card-prep_001')).hitTestable());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('leave-feedback-prep_001')), findsNothing);
  });
}

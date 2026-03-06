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
import 'package:plateful/src/features/feedback/feedback_screen.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearAll);

  Future<void> seedOrder(WidgetTester tester) async {
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

    await tester.runAsync(() async {
      await Hive.box<String>('orders').put(
        'orders_list',
        jsonEncode([order.toJson()]),
      );
    });
  }

  Future<void> pumpFeedbackApp(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    final router = GoRouter(
      initialLocation: '/feedback/order_1',
      routes: [
        GoRoute(
          path: '/feedback/:orderId',
          builder: (context, state) => const FeedbackScreen(),
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

  testWidgets('submit enables only after all ratings and shows success modal',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await seedOrder(tester);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await pumpFeedbackApp(tester, container);

    final submitButton = tester.widget<ElevatedButton>(
      find.descendant(
        of: find.byKey(const Key('feedback-submit-button')),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(submitButton.onPressed, isNull);

    await tester
        .ensureVisible(find.byKey(const Key('feedback-star-overall-5')));
    await tester.tap(find.byKey(const Key('feedback-star-overall-5')));
    await tester
        .ensureVisible(find.byKey(const Key('feedback-star-foodQuality-5')));
    await tester.tap(find.byKey(const Key('feedback-star-foodQuality-5')));
    await tester
        .ensureVisible(find.byKey(const Key('feedback-star-portionSize-5')));
    await tester.tap(find.byKey(const Key('feedback-star-portionSize-5')));
    await tester
        .ensureVisible(find.byKey(const Key('feedback-star-serviceSpeed-5')));
    await tester.tap(find.byKey(const Key('feedback-star-serviceSpeed-5')));
    await tester.pump();

    final enabledButton = tester.widget<ElevatedButton>(
      find.descendant(
        of: find.byKey(const Key('feedback-submit-button')),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(enabledButton.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('feedback-submit-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Thank You!'), findsOneWidget);
  });
}

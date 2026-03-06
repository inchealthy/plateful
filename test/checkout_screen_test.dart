import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plateful/src/app/themes/app_theme.dart';
import 'package:plateful/src/common/domain/entities/cart_item.dart';
import 'package:plateful/src/common/domain/entities/menu_item.dart';
import 'package:plateful/src/features/cart/cart_controller.dart';
import 'package:plateful/src/features/checkout/checkout_screen.dart';
import 'package:plateful/src/features/orders/orders_controller.dart';
import 'package:plateful/src/features/checkout/checkout_controller.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearAll);

  Future<void> pumpCheckoutApp(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    final router = GoRouter(
      initialLocation: '/checkout',
      routes: [
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/shell/orders',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Orders Stub'))),
        ),
        GoRoute(
          path: '/shell/home',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home Stub'))),
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

  testWidgets('checkout flow: schedule toggle, place order, and track order',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        orderProgressSimulationEnabledProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);

    container.read(cartProvider.notifier).addItem(
          const CartItem(item: item, quantity: 1),
          restaurantName: 'Main Campus Cafeteria',
        );

    await pumpCheckoutApp(tester, container);

    expect(find.byKey(const Key('schedule-time-button')), findsNothing);
    container.read(checkoutProvider.notifier).togglePickupMode(false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const Key('schedule-time-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('place-order-button')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Order Placed!'), findsOneWidget);

    await tester.tap(find.byKey(const Key('track-order-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Orders Stub'), findsOneWidget);
    expect(container.read(cartProvider).items, isEmpty);
    expect(container.read(ordersProvider).orders, isNotEmpty);
  });
}

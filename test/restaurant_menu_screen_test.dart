import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plateful/src/app/themes/app_theme.dart';
import 'package:plateful/src/features/cart/cart_controller.dart';
import 'package:plateful/src/features/restaurant_menu/restaurant_menu_screen.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearCart);

  Future<void> pumpMenuApp(
    WidgetTester tester,
    ProviderContainer container, {
    required GoRouter router,
  }) async {
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
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        break;
      }
    }
  }

  GoRouter buildMenuRouter({required String restaurantId}) {
    return GoRouter(
      initialLocation: '/restaurant/$restaurantId',
      routes: [
        GoRoute(
          path: '/restaurant/:restaurantId',
          builder: (context, state) => const RestaurantMenuScreen(),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Cart Route'))),
        ),
      ],
    );
  }

  testWidgets('menu screen renders selected restaurant', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/restaurant/r1',
      routes: [
        GoRoute(
          path: '/restaurant/:restaurantId',
          builder: (context, state) => const RestaurantMenuScreen(),
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

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        break;
      }
    }

    expect(find.text('Main Campus Cafeteria'), findsOneWidget);
  });

  testWidgets('open item sheet and add to cart shows CartFAB', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = buildMenuRouter(restaurantId: 'r1');
    addTearDown(router.dispose);

    await pumpMenuApp(tester, container, router: router);

    expect(find.text('Main Campus Cafeteria'), findsOneWidget);
    await tester.tap(find.byKey(const Key('menu-item-m1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Add to Cart'), findsOneWidget);
    await tester.tap(find.byKey(const Key('item-sheet-add-button-m1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(container.read(cartProvider).items, isNotEmpty);
    expect(find.byKey(const Key('cart-fab')), findsOneWidget);
  });

  testWidgets('menu card add swaps to inline stepper and syncs qty', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = buildMenuRouter(restaurantId: 'r1');
    addTearDown(router.dispose);

    await pumpMenuApp(tester, container, router: router);

    expect(find.byKey(const Key('menu-item-add-m1')), findsOneWidget);
    expect(find.byKey(const Key('menu-item-stepper-m1')), findsNothing);

    await tester.tap(find.byKey(const Key('menu-item-add-m1')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(container.read(cartProvider).items.first.quantity, 1);
    expect(find.byKey(const Key('menu-item-stepper-m1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('menu-item-plus-m1')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(cartProvider).items.first.quantity, 2);

    await tester.tap(find.byKey(const Key('menu-item-minus-m1')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(cartProvider).items.first.quantity, 1);

    await tester.tap(find.byKey(const Key('menu-item-minus-m1')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(cartProvider).items, isEmpty);
    expect(find.byKey(const Key('menu-item-add-m1')), findsOneWidget);
  });

  testWidgets('closed restaurant blocks quick add', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = buildMenuRouter(restaurantId: 'r5');
    addTearDown(router.dispose);

    await pumpMenuApp(tester, container, router: router);

    expect(find.byKey(const Key('menu-item-add-m23')), findsOneWidget);
    await tester.tap(find.byKey(const Key('menu-item-add-m23')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(container.read(cartProvider).items, isEmpty);
    expect(
      find.text('Restaurant is closed. Ordering unavailable.'),
      findsOneWidget,
    );
  });
}

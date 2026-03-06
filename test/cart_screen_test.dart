import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plateful/src/app/themes/app_theme.dart';
import 'package:plateful/src/common/domain/entities/cart_item.dart';
import 'package:plateful/src/common/domain/entities/menu_item.dart';
import 'package:plateful/src/features/cart/cart_controller.dart';
import 'package:plateful/src/features/cart/cart_screen.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearCart);

  Future<void> pumpCartApp(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    final router = GoRouter(
      initialLocation: '/cart',
      routes: [
        GoRoute(
          path: '/cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Checkout Stub'))),
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

    await tester.pumpAndSettle();
  }

  testWidgets('qty update, delete, and empty state flow', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(cartProvider.notifier).addItem(
          CartItem(
            item: const MenuItem(
              id: 'm1',
              restaurantId: 'r1',
              name: 'Canyon Classic Burger',
              description: 'desc',
              emoji: '🍔',
              category: 'Lunch',
              price: 8.5,
              calories: 100,
              carbs: 10,
              protein: 5,
              fat: 2,
              allergens: [],
              dietaryTags: [],
            ),
            quantity: 1,
          ),
          restaurantName: 'Main Campus Cafeteria',
        );

    await pumpCartApp(tester, container);

    expect(find.text('Canyon Classic Burger'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cart-plus-m1')));
    await tester.pumpAndSettle();
    expect(container.read(cartProvider).items.first.quantity, 2);

    await tester.tap(find.byKey(const Key('cart-delete-m1')));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);

    await tester.tap(find.text('Browse Restaurants'));
    await tester.pumpAndSettle();
    expect(find.text('Home Stub'), findsOneWidget);
  });
}

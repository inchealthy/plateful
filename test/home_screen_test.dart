import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plateful/src/common/domain/entities/cart_item.dart';
import 'package:plateful/src/common/domain/entities/menu_item.dart';
import 'package:plateful/src/features/cart/cart_controller.dart';
import 'package:plateful/src/features/home/home_controller.dart';
import 'package:plateful/src/features/home/home_screen.dart';
import 'package:plateful/src/features/home/widgets/restaurant_list_view.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearCart);

  testWidgets('Home list/search/toggle flow works', (tester) async {
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      ),
    );

    await container.read(homeProvider.notifier).loadRestaurants();
    await tester.pump();

    expect(find.byType(SafeArea), findsNothing);
    expect(container.read(homeProvider).filteredList.length, 6);
    expect(find.byType(RestaurantListView), findsOneWidget);
    expect(find.byKey(const Key('cart-fab')), findsOneWidget);
    expect(find.text('Main Campus Cafeteria'), findsOneWidget);

    container.read(homeProvider.notifier).onSearchChanged('zzzz-not-found');
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('No restaurants found'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-toggle-map')));
    await tester.pump(const Duration(seconds: 2));
    expect(container.read(homeProvider).selectedTabIndex, 1);

    await tester.tap(find.byKey(const Key('home-toggle-list')));
    await tester.pump(const Duration(seconds: 2));
    expect(container.read(homeProvider).selectedTabIndex, 0);
  });
}

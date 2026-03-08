import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
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
  setUp(() async {
    await HiveTestHelper.clearCart();
    await HiveTestHelper.clearProfile();
  });

  testWidgets('Home list/search/toggle/change-location flow works', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        locationClientProvider.overrideWithValue(
          const FakeLocationClient(permission: LocationPermission.denied),
        ),
      ],
    );
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
          builder: (_, __) => const MaterialApp(home: HomeScreen()),
        ),
      ),
    );
    await container.read(homeProvider.notifier).loadRestaurants();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SafeArea), findsNothing);
    expect(container.read(homeProvider).filteredList.length, 2);
    expect(find.byType(RestaurantListView), findsOneWidget);
    expect(find.byKey(const Key('cart-fab')), findsOneWidget);
    expect(find.text('Main Campus Cafeteria'), findsOneWidget);
    expect(find.text('Canyon College'), findsOneWidget);

    container.read(homeProvider.notifier).onSearchChanged('zzzz-not-found');
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('No restaurants found'), findsOneWidget);

    container.read(homeProvider.notifier).onLocationChanged(
          'loc_harbor_hospital',
        );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Harbor Hospital'), findsOneWidget);
    expect(
      container.read(homeProvider).selectedLocationId,
      'loc_harbor_hospital',
    );
  });
}

class FakeLocationClient implements LocationClient {
  const FakeLocationClient({required this.permission, this.coordinate});

  final LocationPermission permission;
  final UserCoordinate? coordinate;

  @override
  Future<LocationPermission> requestPermission() async => permission;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<UserCoordinate?> getCurrentCoordinate() async => coordinate;
}

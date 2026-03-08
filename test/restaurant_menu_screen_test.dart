import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plateful/src/app/themes/app_theme.dart';
import 'package:plateful/src/features/restaurant_menu/restaurant_menu_screen.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);

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
}

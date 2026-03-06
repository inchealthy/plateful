import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plateful/src/features/home/home_controller.dart';
import 'package:plateful/src/features/home/home_screen.dart';
import 'package:plateful/src/features/home/widgets/restaurant_list_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home list/search/toggle flow works', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await container.read(homeProvider.notifier).loadRestaurants();
    await tester.pump();

    expect(container.read(homeProvider).filteredList.length, 6);
    expect(find.byType(RestaurantListView), findsOneWidget);
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

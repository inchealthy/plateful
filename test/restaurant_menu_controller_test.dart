import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plateful/src/features/restaurant_menu/restaurant_menu_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads restaurant and menu items by restaurantId', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(restaurantMenuProvider('r1').notifier);
    await notifier.loadData('r1');

    final state = container.read(restaurantMenuProvider('r1'));
    expect(state.isLoading, false);
    expect(state.restaurant?.id, 'r1');
    expect(state.allItems, isNotEmpty);
    expect(state.allItems.every((item) => item.restaurantId == 'r1'), true);
    expect(
      state.availableCategories,
      ['All', 'Breakfast', 'Lunch', 'Dinner'],
    );
  });

  test('category filter updates filteredItems', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(restaurantMenuProvider('r3').notifier);
    await notifier.loadData('r3');

    notifier.onCategoryChanged('Beverages');
    final state = container.read(restaurantMenuProvider('r3'));

    expect(state.selectedCategory, 'Beverages');
    expect(state.filteredItems, isNotEmpty);
    expect(
      state.filteredItems.every((item) => item.category == 'Beverages'),
      true,
    );
  });
}

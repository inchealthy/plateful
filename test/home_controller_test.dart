import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plateful/src/features/home/home_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> load(ProviderContainer container) async {
    final notifier = container.read(homeProvider.notifier);
    await notifier.loadRestaurants();
  }

  group('HomeController filters', () {
    test('query filter works', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await load(container);
      container.read(homeProvider.notifier).onSearchChanged('coffee');

      final state = container.read(homeProvider);
      expect(state.filteredList.length, 1);
      expect(state.filteredList.first.id, 'r3');
    });

    test('chip filter and re-tap reset', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await load(container);
      container.read(homeProvider.notifier).onFilterSelected('Lunch');
      var state = container.read(homeProvider);
      expect(state.filteredList.length, 4);
      expect(state.selectedFilter, 'Lunch');

      container.read(homeProvider.notifier).onFilterSelected('Lunch');
      state = container.read(homeProvider);
      expect(state.selectedFilter, 'All');
      expect(state.filteredList.length, 6);
    });

    test('combined query + chip filter works', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await load(container);
      final notifier = container.read(homeProvider.notifier);
      notifier.onFilterSelected('Vegan');
      notifier.onSearchChanged('garden');

      final state = container.read(homeProvider);
      expect(state.filteredList.length, 1);
      expect(state.filteredList.first.id, 'r5');
    });
  });
}

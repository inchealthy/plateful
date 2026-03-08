import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plateful/src/features/home/home_controller.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearProfile);

  Future<void> load(ProviderContainer container) async {
    await container.read(homeProvider.notifier).loadRestaurants();
  }

  group('HomeController filters + location', () {
    test('query filter works in selected location', () async {
      final container = ProviderContainer(
        overrides: [
          locationClientProvider.overrideWithValue(
            const FakeLocationClient(permission: LocationPermission.denied),
          ),
        ],
      );
      addTearDown(container.dispose);

      await load(container);
      final state = container.read(homeProvider);
      expect(state.selectedLocationId, 'loc_canyon_college');

      container.read(homeProvider.notifier).onSearchChanged('coffee');
      final updatedState = container.read(homeProvider);

      expect(updatedState.filteredList.length, 1);
      expect(updatedState.filteredList.first.id, 'r3');
    });

    test('menu-aware query honors selected location', () async {
      final container = ProviderContainer(
        overrides: [
          locationClientProvider.overrideWithValue(
            const FakeLocationClient(permission: LocationPermission.denied),
          ),
        ],
      );
      addTearDown(container.dispose);

      await load(container);
      container.read(homeProvider.notifier).onSearchChanged('burger');

      final ids = container
          .read(homeProvider)
          .filteredList
          .map((restaurant) => restaurant.id)
          .toSet();

      expect(ids.contains('r1'), isTrue);
      expect(ids.contains('r4'), isFalse);
    });

    test('chip filter and re-tap reset', () async {
      final container = ProviderContainer(
        overrides: [
          locationClientProvider.overrideWithValue(
            const FakeLocationClient(permission: LocationPermission.denied),
          ),
        ],
      );
      addTearDown(container.dispose);

      await load(container);
      container.read(homeProvider.notifier).onFilterSelected('Lunch');
      var state = container.read(homeProvider);
      expect(state.filteredList.length, 1);
      expect(state.selectedFilter, 'Lunch');

      container.read(homeProvider.notifier).onFilterSelected('Lunch');
      state = container.read(homeProvider);
      expect(state.selectedFilter, 'All');
      expect(state.filteredList.length, 2);
    });

    test('combined query + chip filter works', () async {
      final container = ProviderContainer(
        overrides: [
          locationClientProvider.overrideWithValue(
            const FakeLocationClient(permission: LocationPermission.denied),
          ),
        ],
      );
      addTearDown(container.dispose);

      await load(container);
      final notifier = container.read(homeProvider.notifier);
      notifier.onFilterSelected('Vegan');
      notifier.onSearchChanged('garden');

      final state = container.read(homeProvider);
      final ids = state.filteredList.map((restaurant) => restaurant.id).toSet();
      expect(ids.contains('r1'), isTrue);
      expect(state.filteredList.length, 1);
    });

    test(
      'first install + granted permission auto-selects nearest location',
      () async {
        final container = ProviderContainer(
          overrides: [
            locationClientProvider.overrideWithValue(
              const FakeLocationClient(
                permission: LocationPermission.whileInUse,
                coordinate: UserCoordinate(
                  latitude: 34.0651,
                  longitude: -118.4507,
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await load(container);
        final state = container.read(homeProvider);

        expect(state.selectedLocationId, 'loc_harbor_hospital');
        expect(state.hasLocationPermission, isTrue);
        expect(state.rankedLocations.first.id, 'loc_harbor_hospital');
        expect(state.locationDistanceKmById['loc_harbor_hospital'], isNotNull);
      },
    );

    test('saved selected location survives permission revoke', () async {
      final containerA = ProviderContainer(
        overrides: [
          locationClientProvider.overrideWithValue(
            const FakeLocationClient(
              permission: LocationPermission.whileInUse,
              coordinate: UserCoordinate(
                latitude: 34.0716,
                longitude: -118.4448,
              ),
            ),
          ),
        ],
      );
      await load(containerA);
      containerA
          .read(homeProvider.notifier)
          .onLocationChanged('loc_northside_academy');
      containerA.dispose();

      final containerB = ProviderContainer(
        overrides: [
          locationClientProvider.overrideWithValue(
            const FakeLocationClient(permission: LocationPermission.denied),
          ),
        ],
      );
      addTearDown(containerB.dispose);

      await load(containerB);
      final state = containerB.read(homeProvider);
      expect(state.selectedLocationId, 'loc_northside_academy');
      expect(state.hasLocationPermission, isFalse);
    });
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

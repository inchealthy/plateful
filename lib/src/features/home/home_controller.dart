import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../common/domain/entities/building_location.dart';
import '../../common/domain/entities/menu_item.dart';
import '../../common/domain/entities/restaurant.dart';
import 'home_state.dart';

class HomeController extends Notifier<HomeState> {
  static const _profileBoxName = 'profile';
  static const _locationPrefsKey = 'location_prefs';
  static const _selectedLocationIdKey = 'selected_location_id';
  static const _locationPermissionRequestedKey =
      'location_permission_requested';

  Map<String, List<MenuItem>> _menuItemsByRestaurant = const {};
  late final Box<String> _profileBox;
  late final LocationClient _locationClient;
  Future<void>? _bootstrapFuture;

  @override
  HomeState build() {
    _profileBox = Hive.box<String>(_profileBoxName);
    _locationClient = ref.read(locationClientProvider);
    Future.microtask(loadRestaurants);
    return const HomeState(isLoading: true);
  }

  Future<void> loadRestaurants() async {
    if (_bootstrapFuture != null) {
      await _bootstrapFuture;
      return;
    }

    _bootstrapFuture = () async {
      final restaurantsStr = await rootBundle.loadString(
        'assets/jsons/restaurants.json',
      );
      final menuItemsStr = await rootBundle.loadString(
        'assets/jsons/menu_items.json',
      );
      final locationsStr = await rootBundle.loadString(
        'assets/jsons/locations.json',
      );

      final restaurants = (jsonDecode(restaurantsStr) as List<dynamic>)
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList();
      final menuItems = (jsonDecode(menuItemsStr) as List<dynamic>)
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final locations = (jsonDecode(locationsStr) as List<dynamic>)
          .map((e) => BuildingLocation.fromJson(e as Map<String, dynamic>))
          .toList();

      final byRestaurant = <String, List<MenuItem>>{};
      for (final item in menuItems) {
        byRestaurant.putIfAbsent(item.restaurantId, () => []).add(item);
      }
      _menuItemsByRestaurant = byRestaurant;

      final prefs = _readLocationPrefs();
      final savedLocationId = prefs[_selectedLocationIdKey] as String?;
      var hasRequestedPermission =
          prefs[_locationPermissionRequestedKey] as bool? ?? false;

      final permission = hasRequestedPermission
          ? await _safeCheckPermission()
          : await _safeRequestPermission();
      if (!hasRequestedPermission) {
        hasRequestedPermission = true;
      }

      final hasLocationPermission = _isPermissionGranted(permission);
      final userCoordinate =
          hasLocationPermission ? await _safeGetCurrentCoordinate() : null;

      final ranking = _rankLocations(
        locations: locations,
        userCoordinate: userCoordinate,
      );

      final selectedLocationId = _resolveSelectedLocationId(
        locations: locations,
        rankedLocations: ranking.locations,
        savedLocationId: savedLocationId,
        hasLocationPermission: hasLocationPermission,
      );

      _persistLocationPrefs(
        selectedLocationId: selectedLocationId,
        hasRequestedPermission: hasRequestedPermission,
      );

      state = state.copyWith(
        allRestaurants: restaurants,
        locations: locations,
        rankedLocations: ranking.locations,
        locationDistanceKmById: ranking.distanceKmById,
        selectedLocationId: selectedLocationId,
        hasLocationPermission: hasLocationPermission,
        isLoading: false,
      );
      _applyFilters();
    }();

    try {
      await _bootstrapFuture;
    } catch (_) {
      _menuItemsByRestaurant = const {};
      state = state.copyWith(
        allRestaurants: const [],
        filteredList: const [],
        locations: const [],
        rankedLocations: const [],
        locationDistanceKmById: const {},
        selectedLocationId: '',
        hasLocationPermission: false,
        isLoading: false,
      );
    } finally {
      _bootstrapFuture = null;
    }
  }

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void onFilterSelected(String filter) {
    final newFilter = state.selectedFilter == filter ? 'All' : filter;
    state = state.copyWith(selectedFilter: newFilter);
    _applyFilters();
  }

  void onTabChanged(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  void onLocationChanged(String locationId) {
    if (state.selectedLocationId == locationId) {
      return;
    }
    final hasLocation = state.locations.any((item) => item.id == locationId);
    if (!hasLocation) {
      return;
    }

    state = state.copyWith(selectedLocationId: locationId);
    _applyFilters();
    _persistLocationPrefs(selectedLocationId: locationId);
  }

  void _applyFilters() {
    var result = state.selectedLocationId.isEmpty
        ? state.allRestaurants
        : state.allRestaurants
            .where((r) => r.locationId == state.selectedLocationId)
            .toList();

    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      result = result
          .where(
            (r) =>
                r.name.toLowerCase().contains(q) ||
                r.cuisine.toLowerCase().contains(q) ||
                r.tags.any((t) => t.toLowerCase().contains(q)) ||
                (_menuItemsByRestaurant[r.id] ?? const []).any(
                  (item) =>
                      item.name.toLowerCase().contains(q) ||
                      item.description.toLowerCase().contains(q) ||
                      item.category.toLowerCase().contains(q) ||
                      item.dietaryTags.any(
                        (tag) => tag.toLowerCase().contains(q),
                      ),
                ),
          )
          .toList();
    }

    if (state.selectedFilter != 'All') {
      result =
          result.where((r) => r.tags.contains(state.selectedFilter)).toList();
    }

    state = state.copyWith(filteredList: result);
  }

  bool _isPermissionGranted(LocationPermission permission) {
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<LocationPermission> _safeRequestPermission() async {
    try {
      return await _locationClient.requestPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  Future<LocationPermission> _safeCheckPermission() async {
    try {
      return await _locationClient.checkPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  Future<UserCoordinate?> _safeGetCurrentCoordinate() async {
    try {
      return await _locationClient.getCurrentCoordinate();
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _readLocationPrefs() {
    final raw = _profileBox.get(_locationPrefsKey);
    if (raw == null || raw.isEmpty) {
      return const {};
    }

    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        return json;
      }
      return const {};
    } catch (_) {
      return const {};
    }
  }

  void _persistLocationPrefs({
    String? selectedLocationId,
    bool? hasRequestedPermission,
  }) {
    final existing = _readLocationPrefs();
    final payload = <String, dynamic>{
      _selectedLocationIdKey:
          selectedLocationId ?? existing[_selectedLocationIdKey],
      _locationPermissionRequestedKey: hasRequestedPermission ??
          existing[_locationPermissionRequestedKey] ??
          false,
    };
    _profileBox.put(_locationPrefsKey, jsonEncode(payload));
  }

  String _resolveSelectedLocationId({
    required List<BuildingLocation> locations,
    required List<BuildingLocation> rankedLocations,
    required String? savedLocationId,
    required bool hasLocationPermission,
  }) {
    if (locations.isEmpty) {
      return '';
    }

    final hasSaved = savedLocationId != null &&
        locations.any((location) => location.id == savedLocationId);
    if (hasSaved) {
      return savedLocationId;
    }

    if (hasLocationPermission && rankedLocations.isNotEmpty) {
      return rankedLocations.first.id;
    }

    return locations.first.id;
  }

  _LocationRanking _rankLocations({
    required List<BuildingLocation> locations,
    required UserCoordinate? userCoordinate,
  }) {
    if (locations.isEmpty) {
      return const _LocationRanking(locations: [], distanceKmById: {});
    }

    if (userCoordinate == null) {
      return _LocationRanking(
        locations: List<BuildingLocation>.from(locations),
        distanceKmById: const {},
      );
    }

    final distanceKmById = <String, double>{};
    for (final location in locations) {
      final meters = Geolocator.distanceBetween(
        userCoordinate.latitude,
        userCoordinate.longitude,
        location.lat,
        location.lng,
      );
      distanceKmById[location.id] = meters / 1000;
    }

    final ranked = List<BuildingLocation>.from(locations)
      ..sort((a, b) {
        final aDistance = distanceKmById[a.id] ?? double.infinity;
        final bDistance = distanceKmById[b.id] ?? double.infinity;
        final byDistance = aDistance.compareTo(bDistance);
        if (byDistance != 0) {
          return byDistance;
        }
        return a.name.compareTo(b.name);
      });

    return _LocationRanking(locations: ranked, distanceKmById: distanceKmById);
  }
}

final homeProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

final locationClientProvider = Provider<LocationClient>((ref) {
  return const GeolocatorLocationClient();
});

class UserCoordinate {
  const UserCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

abstract class LocationClient {
  Future<LocationPermission> requestPermission();
  Future<LocationPermission> checkPermission();
  Future<UserCoordinate?> getCurrentCoordinate();
}

class GeolocatorLocationClient implements LocationClient {
  const GeolocatorLocationClient();

  @override
  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }

  @override
  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  @override
  Future<UserCoordinate?> getCurrentCoordinate() async {
    final position = await Geolocator.getCurrentPosition();
    return UserCoordinate(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

class _LocationRanking {
  const _LocationRanking({
    required this.locations,
    required this.distanceKmById,
  });

  final List<BuildingLocation> locations;
  final Map<String, double> distanceKmById;
}

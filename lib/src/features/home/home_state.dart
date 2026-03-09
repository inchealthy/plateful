import '../../common/domain/entities/building_location.dart';
import '../../common/domain/entities/restaurant.dart';
import 'home_controller.dart';

class HomeState {
  const HomeState({
    this.allRestaurants = const [],
    this.filteredList = const [],
    this.searchQuery = '',
    this.selectedFilter = 'All',
    this.selectedTabIndex = 0,
    this.locations = const [],
    this.rankedLocations = const [],
    this.locationDistanceKmById = const {},
    this.selectedLocationId = '',
    this.hasLocationPermission = false,
    this.isLoading = false,
    this.userCoordinate,
  });

  final List<Restaurant> allRestaurants;
  final List<Restaurant> filteredList;
  final String searchQuery;
  final String selectedFilter;
  final int selectedTabIndex;
  final List<BuildingLocation> locations;
  final List<BuildingLocation> rankedLocations;
  final Map<String, double> locationDistanceKmById;
  final String selectedLocationId;
  final bool hasLocationPermission;
  final bool isLoading;
  final UserCoordinate? userCoordinate;

  BuildingLocation? get selectedLocation {
    if (selectedLocationId.isEmpty) {
      return null;
    }
    for (final location in locations) {
      if (location.id == selectedLocationId) {
        return location;
      }
    }
    return null;
  }

  HomeState copyWith({
    List<Restaurant>? allRestaurants,
    List<Restaurant>? filteredList,
    String? searchQuery,
    String? selectedFilter,
    int? selectedTabIndex,
    List<BuildingLocation>? locations,
    List<BuildingLocation>? rankedLocations,
    Map<String, double>? locationDistanceKmById,
    String? selectedLocationId,
    bool? hasLocationPermission,
    bool? isLoading,
    UserCoordinate? userCoordinate,
  }) {
    return HomeState(
      allRestaurants: allRestaurants ?? this.allRestaurants,
      filteredList: filteredList ?? this.filteredList,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      locations: locations ?? this.locations,
      rankedLocations: rankedLocations ?? this.rankedLocations,
      locationDistanceKmById:
          locationDistanceKmById ?? this.locationDistanceKmById,
      selectedLocationId: selectedLocationId ?? this.selectedLocationId,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      isLoading: isLoading ?? this.isLoading,
      userCoordinate: userCoordinate ?? this.userCoordinate,
    );
  }
}

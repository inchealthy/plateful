import '../../common/domain/entities/restaurant.dart';

class HomeState {
  const HomeState({
    this.allRestaurants = const [],
    this.filteredList = const [],
    this.searchQuery = '',
    this.selectedFilter = 'All',
    this.selectedTabIndex = 0,
    this.isLoading = false,
  });

  final List<Restaurant> allRestaurants;
  final List<Restaurant> filteredList;
  final String searchQuery;
  final String selectedFilter;
  final int selectedTabIndex;
  final bool isLoading;

  HomeState copyWith({
    List<Restaurant>? allRestaurants,
    List<Restaurant>? filteredList,
    String? searchQuery,
    String? selectedFilter,
    int? selectedTabIndex,
    bool? isLoading,
  }) {
    return HomeState(
      allRestaurants: allRestaurants ?? this.allRestaurants,
      filteredList: filteredList ?? this.filteredList,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

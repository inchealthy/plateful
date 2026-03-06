import '../../common/domain/entities/menu_item.dart';
import '../../common/domain/entities/restaurant.dart';

class RestaurantMenuState {
  const RestaurantMenuState({
    this.restaurant,
    this.allItems = const [],
    this.filteredItems = const [],
    this.selectedCategory = 'All',
    this.isLoading = true,
  });

  final Restaurant? restaurant;
  final List<MenuItem> allItems;
  final List<MenuItem> filteredItems;
  final String selectedCategory;
  final bool isLoading;

  static const _baseOrder = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Beverages',
  ];

  List<String> get availableCategories {
    final all = allItems.map((e) => e.category).toSet();
    final ordered = _baseOrder.where(all.contains).toList();
    final extras = all.where((e) => !_baseOrder.contains(e)).toList()..sort();
    return ['All', ...ordered, ...extras];
  }

  RestaurantMenuState copyWith({
    Restaurant? restaurant,
    List<MenuItem>? allItems,
    List<MenuItem>? filteredItems,
    String? selectedCategory,
    bool? isLoading,
    bool clearRestaurant = false,
  }) {
    return RestaurantMenuState(
      restaurant: clearRestaurant ? null : (restaurant ?? this.restaurant),
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

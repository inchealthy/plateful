import '../../common/domain/entities/add_on.dart';
import '../../common/domain/entities/menu_item.dart';
import '../../common/domain/entities/restaurant.dart';

class RestaurantMenuState {
  const RestaurantMenuState({
    this.restaurant,
    this.allItems = const [],
    this.filteredItems = const [],
    this.selectedCategory = 'All',
    this.addOnGroups = const [],
    this.isLoading = true,
  });

  final Restaurant? restaurant;
  final List<MenuItem> allItems;
  final List<MenuItem> filteredItems;
  final String selectedCategory;
  final List<AddOnGroup> addOnGroups;
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

  List<AddOnGroup> addOnGroupsForItem(String itemId) {
    return addOnGroups
        .where((g) => g.applicableItemIds.contains(itemId))
        .toList();
  }

  RestaurantMenuState copyWith({
    Restaurant? restaurant,
    List<MenuItem>? allItems,
    List<MenuItem>? filteredItems,
    String? selectedCategory,
    List<AddOnGroup>? addOnGroups,
    bool? isLoading,
    bool clearRestaurant = false,
  }) {
    return RestaurantMenuState(
      restaurant: clearRestaurant ? null : (restaurant ?? this.restaurant),
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      addOnGroups: addOnGroups ?? this.addOnGroups,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

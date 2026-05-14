import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/domain/entities/add_on.dart';
import '../../common/domain/entities/menu_item.dart';
import '../../common/domain/entities/restaurant.dart';
import 'restaurant_menu_state.dart';

class RestaurantMenuController
    extends FamilyNotifier<RestaurantMenuState, String> {
  @override
  RestaurantMenuState build(String restaurantId) {
    Future.microtask(() => loadData(restaurantId));
    return const RestaurantMenuState();
  }

  Future<void> loadData(String restaurantId) async {
    state = state.copyWith(isLoading: true);

    try {
      final restaurantsRaw =
          await rootBundle.loadString('assets/jsons/restaurants.json');
      final menuItemsRaw =
          await rootBundle.loadString('assets/jsons/menu_items.json');
      final addonsRaw =
          await rootBundle.loadString('assets/jsons/addons.json');

      final restaurants = (jsonDecode(restaurantsRaw) as List<dynamic>)
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList();
      final items = (jsonDecode(menuItemsRaw) as List<dynamic>)
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final allAddOnGroups = (jsonDecode(addonsRaw) as List<dynamic>)
          .map((e) => AddOnGroup.fromJson(e as Map<String, dynamic>))
          .toList();

      Restaurant? restaurant;
      for (final value in restaurants) {
        if (value.id == restaurantId) {
          restaurant = value;
          break;
        }
      }

      final restaurantItems =
          items.where((item) => item.restaurantId == restaurantId).toList();
      final restaurantAddOnGroups = allAddOnGroups
          .where((g) => g.restaurantId == restaurantId)
          .toList();
      final selectedCategory =
          _hasCategory(state.selectedCategory, restaurantItems)
              ? state.selectedCategory
              : 'All';

      state = state.copyWith(
        restaurant: restaurant,
        allItems: restaurantItems,
        filteredItems: _filterByCategory(restaurantItems, selectedCategory),
        selectedCategory: selectedCategory,
        addOnGroups: restaurantAddOnGroups,
        isLoading: false,
      );
    } catch (_) {
      state = const RestaurantMenuState(
        isLoading: false,
      );
    }
  }

  void onCategoryChanged(String category) {
    state = state.copyWith(
      selectedCategory: category,
      filteredItems: _filterByCategory(state.allItems, category),
    );
  }

  List<MenuItem> _filterByCategory(List<MenuItem> items, String category) {
    if (category == 'All') {
      return items;
    }
    return items.where((item) => item.category == category).toList();
  }

  bool _hasCategory(String category, List<MenuItem> items) {
    return category == 'All' || items.any((item) => item.category == category);
  }
}

final restaurantMenuProvider = NotifierProvider.family<RestaurantMenuController,
    RestaurantMenuState, String>(
  RestaurantMenuController.new,
);

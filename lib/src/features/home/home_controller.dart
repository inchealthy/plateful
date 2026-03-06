import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/domain/entities/menu_item.dart';
import '../../common/domain/entities/restaurant.dart';
import 'home_state.dart';

class HomeController extends Notifier<HomeState> {
  Map<String, List<MenuItem>> _menuItemsByRestaurant = const {};

  @override
  HomeState build() {
    Future.microtask(loadRestaurants);
    return const HomeState(isLoading: true);
  }

  Future<void> loadRestaurants() async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/jsons/restaurants.json');
      final menuItemsStr =
          await rootBundle.loadString('assets/jsons/menu_items.json');

      final list = (jsonDecode(jsonStr) as List<dynamic>)
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList();
      final menuItems = (jsonDecode(menuItemsStr) as List<dynamic>)
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList();

      final byRestaurant = <String, List<MenuItem>>{};
      for (final item in menuItems) {
        byRestaurant.putIfAbsent(item.restaurantId, () => []).add(item);
      }
      _menuItemsByRestaurant = byRestaurant;

      state = state.copyWith(
        allRestaurants: list,
        filteredList: list,
        isLoading: false,
      );
      _applyFilters();
    } catch (_) {
      _menuItemsByRestaurant = const {};
      state = state.copyWith(
        allRestaurants: const [],
        filteredList: const [],
        isLoading: false,
      );
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

  void _applyFilters() {
    var result = state.allRestaurants;

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
}

final homeProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

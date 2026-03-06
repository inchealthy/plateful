import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'home_controller.dart';
import 'widgets/filter_chips_bar.dart';
import 'widgets/home_header.dart';
import 'widgets/restaurant_list_view.dart';
import 'widgets/restaurant_map_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _goToRestaurant(String id) {
    context.push('/restaurant/$id');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(
              selectedTabIndex: state.selectedTabIndex,
              onSearchChanged: ref.read(homeProvider.notifier).onSearchChanged,
              onTabChanged: ref.read(homeProvider.notifier).onTabChanged,
            ),
            FilterChipsBar(
              selectedFilter: state.selectedFilter,
              onFilterSelected:
                  ref.read(homeProvider.notifier).onFilterSelected,
            ),
            Expanded(
              child: state.selectedTabIndex == 0
                  ? RestaurantListView(
                      restaurants: state.filteredList,
                      isLoading: state.isLoading,
                      onTapRestaurant: (restaurant) =>
                          _goToRestaurant(restaurant.id),
                    )
                  : RestaurantMapView(
                      restaurants: state.filteredList,
                      onViewMenu: (restaurant) =>
                          _goToRestaurant(restaurant.id),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

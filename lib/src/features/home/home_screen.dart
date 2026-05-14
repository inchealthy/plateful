import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/themes/app_colors.dart';
import '../../common/components/app_search_bar.dart';
import '../../common/domain/entities/building_location.dart';
import '../../common/components/cart_fab.dart';
import '../cart/cart_controller.dart';
import 'home_controller.dart';
import 'widgets/filter_chips_bar.dart';
import 'widgets/home_header.dart';
import 'widgets/location_selector_screen.dart';
import 'widgets/restaurant_list_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _goToRestaurant(String id) {
    context.push('/restaurant/$id');
  }

  Future<void> _openLocationSelector({
    required List<BuildingLocation> locations,
    required String selectedLocationId,
    required Map<String, double> distanceKmById,
    required bool showDistance,
  }) async {
    final nextLocationId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => LocationSelectorScreen(
          locations: locations,
          selectedLocationId: selectedLocationId,
          distanceKmByLocationId: distanceKmById,
          showDistance: showDistance,
        ),
      ),
    );

    if (!mounted || nextLocationId == null || nextLocationId.isEmpty) {
      return;
    }

    ref.read(homeProvider.notifier).onLocationChanged(nextLocationId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final cartState = ref.watch(cartProvider);
    final hasCartItems = cartState.items.isNotEmpty;
    final selectedLocation = state.selectedLocation;
    final currentLocationName = selectedLocation?.name ?? 'Select location';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                HomeHeader(
                  currentLocationName: currentLocationName,
                  onChangeLocationTap: () => _openLocationSelector(
                    locations: state.rankedLocations,
                    selectedLocationId: state.selectedLocationId,
                    distanceKmById: state.locationDistanceKmById,
                    showDistance: state.hasLocationPermission,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: AppSearchBar(
                    onChanged: ref.read(homeProvider.notifier).onSearchChanged,
                    hintText: 'What are you craving?',
                  ),
                ),
                FilterChipsBar(
                  selectedFilter: state.selectedFilter,
                  onFilterSelected:
                      ref.read(homeProvider.notifier).onFilterSelected,
                ),
                Expanded(
                  child: RestaurantListView(
                    restaurants: state.filteredList,
                    isLoading: state.isLoading,
                    bottomPadding: hasCartItems ? 108 : 20,
                    onTapRestaurant: (restaurant) =>
                        _goToRestaurant(restaurant.id),
                  ),
                ),
              ],
            ),
            if (hasCartItems) const CartFAB(),
            Positioned(
              right: 16,
              bottom: hasCartItems ? 88 : 16,
              child: FloatingActionButton(
                key: const Key('home-feedback-fab'),
                heroTag: 'home-feedback-fab',
                backgroundColor: AppColors.primary,
                onPressed: () => context.go('/shell/feedback'),
                child: const Icon(Icons.rate_review, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

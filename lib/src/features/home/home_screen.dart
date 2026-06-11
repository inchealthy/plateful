import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../common/components/app_search_bar.dart';
import '../../common/domain/entities/add_on.dart';
import '../../common/domain/entities/building_location.dart';
import '../../common/components/cart_fab.dart';
import '../cart/cart_controller.dart';
import '../profile/profile_controller.dart';
import '../restaurant_menu/widgets/item_detail_sheet.dart';
import 'home_controller.dart';
import 'home_state.dart';
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

  Future<void> _openItemDetail(MenuItemResult result) async {
    final raw = await rootBundle.loadString('assets/jsons/addons.json');
    final groups = (jsonDecode(raw) as List)
        .map((e) => AddOnGroup.fromJson(e as Map<String, dynamic>))
        .where((g) => g.applicableItemIds.contains(result.item.id))
        .toList();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemDetailSheet(
        item: result.item,
        restaurantName: result.restaurant.name,
        isRestaurantClosed: result.restaurant.status.toLowerCase() == 'closed',
        addOnGroups: groups,
        selectedAllergens: ref.read(profileProvider).selectedAllergens,
      ),
    );
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
                  child: state.searchQuery.isNotEmpty
                      ? _ItemSearchResults(
                          results: state.searchItemResults,
                          bottomPadding: hasCartItems ? 108 : 20,
                          onTap: _openItemDetail,
                        )
                      : RestaurantListView(
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

class _ItemSearchResults extends StatelessWidget {
  const _ItemSearchResults({
    required this.results,
    required this.onTap,
    required this.bottomPadding,
  });

  final List<MenuItemResult> results;
  final ValueChanged<MenuItemResult> onTap;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(child: Text('No items found'));
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = results[index];
        return GestureDetector(
          onTap: () => onTap(r),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(r.item.emoji,
                      style: TextStyle(fontSize: 26.sp)),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.item.name,
                          style: AppTextStyles.heading3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        '${r.restaurant.emoji} ${r.restaurant.name}',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${r.item.price.toStringAsFixed(2)}',
                      style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${r.item.calories.toInt()} kcal',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

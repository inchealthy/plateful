import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/themes/app_colors.dart';
import '../../common/components/cart_fab.dart';
import '../cart/cart_controller.dart';
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
    final cartState = ref.watch(cartProvider);
    final hasCartItems = cartState.items.isNotEmpty;
    final isListTab = state.selectedTabIndex == 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                HomeHeader(
                  selectedTabIndex: state.selectedTabIndex,
                  onSearchChanged:
                      ref.read(homeProvider.notifier).onSearchChanged,
                  onTabChanged: ref.read(homeProvider.notifier).onTabChanged,
                ),
                FilterChipsBar(
                  selectedFilter: state.selectedFilter,
                  onFilterSelected:
                      ref.read(homeProvider.notifier).onFilterSelected,
                ),
                Expanded(
                  child: isListTab
                      ? RestaurantListView(
                          restaurants: state.filteredList,
                          isLoading: state.isLoading,
                          bottomPadding: hasCartItems ? 108 : 20,
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
            if (hasCartItems && isListTab) const CartFAB(),
            if (hasCartItems && !isListTab)
              Positioned(
                key: const Key('home-map-cart-fab'),
                right: 16,
                bottom: 84,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FloatingActionButton(
                      heroTag: 'home-map-cart-fab-btn',
                      mini: true,
                      backgroundColor: AppColors.primary,
                      onPressed: () => context.push('/cart'),
                      child:
                          const Icon(Icons.shopping_cart, color: Colors.white),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: Text(
                          '${cartState.totalItems}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

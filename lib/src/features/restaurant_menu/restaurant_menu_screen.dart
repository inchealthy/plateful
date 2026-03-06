import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../common/components/cart_fab.dart';
import '../../common/domain/entities/cart_item.dart';
import '../../common/domain/entities/menu_item.dart';
import '../cart/cart_controller.dart';
import 'restaurant_menu_controller.dart';
import 'widgets/item_detail_sheet.dart';
import 'widgets/menu_category_tabs.dart';
import 'widgets/menu_section.dart';
import 'widgets/restaurant_sliver_header.dart';

class RestaurantMenuScreen extends ConsumerStatefulWidget {
  const RestaurantMenuScreen({super.key});

  @override
  ConsumerState<RestaurantMenuScreen> createState() =>
      _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends ConsumerState<RestaurantMenuScreen> {
  bool _isRestaurantClosed(String status) {
    return status.toLowerCase() == 'closed';
  }

  void _showRestaurantClosedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: const Text('Restaurant is closed. Ordering unavailable.'),
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 90.h),
      ),
    );
  }

  Future<void> _openItemDetailSheet(
    BuildContext context,
    MenuItem item,
    String restaurantName,
    bool isRestaurantClosed,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ItemDetailSheet(
          item: item,
          restaurantName: restaurantName,
          isRestaurantClosed: isRestaurantClosed,
        );
      },
    );
  }

  Future<void> _handleIncrementItem(
    BuildContext context,
    MenuItem item,
    String restaurantName,
    bool isRestaurantClosed,
  ) async {
    if (isRestaurantClosed) {
      _showRestaurantClosedMessage(context);
      return;
    }

    final cartState = ref.read(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    if (cartState.items.isNotEmpty &&
        cartNotifier.hasConflictWithRestaurant(item.restaurantId)) {
      await _showConflictDialog(
        context,
        previousRestaurantName:
            cartState.restaurantName ?? 'another restaurant',
        item: item,
        restaurantName: restaurantName,
      );
      return;
    }

    cartNotifier.addItem(
      CartItem(item: item, quantity: 1),
      restaurantName: restaurantName,
    );
  }

  void _handleDecrementItem(
    MenuItem item,
    int currentQuantity,
  ) {
    if (currentQuantity <= 0) {
      return;
    }
    ref.read(cartProvider.notifier).updateQuantity(item.id, currentQuantity - 1);
  }

  Future<void> _showConflictDialog(
    BuildContext context, {
    required String previousRestaurantName,
    required MenuItem item,
    required String restaurantName,
  }) async {
    final cartNotifier = ref.read(cartProvider.notifier);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Replace Cart?'),
          content: Text(
            'Your cart has items from $previousRestaurantName. '
            'Clear cart and add from $restaurantName?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cartNotifier.clearAndAdd(
                  CartItem(item: item, quantity: 1),
                  restaurantName: restaurantName,
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Clear & Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurantId =
        GoRouterState.of(context).pathParameters['restaurantId'];

    if (restaurantId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Restaurant Menu')),
        body: const Center(child: Text('Restaurant not found.')),
      );
    }

    final menuState = ref.watch(restaurantMenuProvider(restaurantId));

    if (menuState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final restaurant = menuState.restaurant;
    if (restaurant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Restaurant Menu')),
        body: const Center(child: Text('Restaurant data unavailable.')),
      );
    }

    final cartState = ref.watch(cartProvider);
    final cartQuantityByItem = {
      for (final cartItem in cartState.items) cartItem.item.id: cartItem.quantity,
    };
    final isRestaurantClosed = _isRestaurantClosed(restaurant.status);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                RestaurantSliverHeader(restaurant: restaurant),
                MenuCategoryTabsHeader(
                  categories: menuState.availableCategories,
                  selectedCategory: menuState.selectedCategory,
                  onCategorySelected: ref
                      .read(restaurantMenuProvider(restaurantId).notifier)
                      .onCategoryChanged,
                ),
                MenuSection(
                  selectedCategory: menuState.selectedCategory,
                  items: menuState.filteredItems,
                  itemQuantityOf: (menuItemId) => cartQuantityByItem[menuItemId] ?? 0,
                  isOrderingEnabled: !isRestaurantClosed,
                  onTapItem: (item) => _openItemDetailSheet(
                    context,
                    item,
                    restaurant.name,
                    isRestaurantClosed,
                  ),
                  onIncrementItem: (item) => _handleIncrementItem(
                    context,
                    item,
                    restaurant.name,
                    isRestaurantClosed,
                  ),
                  onDecrementItem: (item) => _handleDecrementItem(
                    item,
                    cartQuantityByItem[item.id] ?? 0,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
            if (cartState.items.isNotEmpty) const CartFAB(),
          ],
        ),
      ),
    );
  }
}

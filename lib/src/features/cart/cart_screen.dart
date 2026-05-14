import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../common/components/app_button.dart';
import 'cart_controller.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/cart_summary_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cartState.items.isEmpty
          ? const _EmptyCartWidget()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartState.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartState.items[index];
                      return CartItemTile(
                        cartItem: cartItem,
                        restaurantName: cartState.restaurantName ?? 'Unknown',
                        onQtyChanged: (quantity) {
                          ref
                              .read(cartProvider.notifier)
                              .updateQuantity(cartItem.cartKey, quantity);
                        },
                        onRemove: () {
                          ref
                              .read(cartProvider.notifier)
                              .removeItem(cartItem.cartKey);
                        },
                      );
                    },
                  ),
                ),
                CartSummaryCard(
                  cartState: cartState,
                  onCheckout: () => context.push('/checkout'),
                ),
              ],
            ),
    );
  }
}

class _EmptyCartWidget extends StatelessWidget {
  const _EmptyCartWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🛒', style: TextStyle(fontSize: 64.sp)),
            SizedBox(height: 8.h),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 6.h),
            Text(
              'Add some delicious food!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20.h),
            AppButton(
              label: 'Browse Restaurants',
              onPressed: () => context.go('/shell/home'),
            ),
          ],
        ),
      ),
    );
  }
}

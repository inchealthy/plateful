import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/domain/entities/order.dart';
import '../cart/cart_controller.dart';
import '../orders/orders_controller.dart';
import 'checkout_state.dart';

class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    return const CheckoutState();
  }

  void togglePickupMode(bool isNow) {
    state = state.copyWith(
      isNow: isNow,
      clearScheduledTime: isNow,
    );
  }

  void setScheduledTime(DateTime time) {
    state = state.copyWith(scheduledTime: time);
  }

  Future<void> placeOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.items.isEmpty) {
      state = state.copyWith(orderPlaced: false, isLoading: false);
      return;
    }

    state = state.copyWith(
      isLoading: true,
      orderPlaced: false,
    );

    await Future<void>.delayed(const Duration(milliseconds: 800));

    final createdAt = DateTime.now();
    final order = Order(
      id: 'order_${createdAt.microsecondsSinceEpoch}',
      restaurantId: cart.restaurantId ?? '',
      restaurantName: cart.restaurantName ?? '',
      items: cart.items,
      createdAt: createdAt,
      status: 'preparing',
      isRated: false,
      total: cart.total,
    );

    ref.read(ordersProvider.notifier).addOrder(order);
    final shouldSimulateProgress =
        ref.read(orderProgressSimulationEnabledProvider);
    if (shouldSimulateProgress) {
      unawaited(
          ref.read(ordersProvider.notifier).simulateOrderProgress(order.id));
    }
    ref.read(cartProvider.notifier).clearCart();

    state = state.copyWith(
      isLoading: false,
      orderPlaced: true,
    );
  }

  void consumeOrderPlaced() {
    if (!state.orderPlaced) {
      return;
    }
    state = state.copyWith(orderPlaced: false);
  }
}

final checkoutProvider = NotifierProvider<CheckoutController, CheckoutState>(
  CheckoutController.new,
);

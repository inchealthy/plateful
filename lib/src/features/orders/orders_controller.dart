import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../common/domain/entities/order.dart';
import 'orders_state.dart';

class OrdersNotifier extends Notifier<OrdersState> {
  static const _boxName = 'orders';
  static const _ordersKey = 'orders_list';

  late Box<String> _box;
  final List<Timer> _simulationTimers = [];

  @override
  OrdersState build() {
    _box = Hive.box<String>(_boxName);
    ref.onDispose(() {
      for (final timer in _simulationTimers) {
        timer.cancel();
      }
      _simulationTimers.clear();
    });
    return OrdersState(
      orders: _loadOrders(),
      isLoading: false,
    );
  }

  List<Order> _loadOrders() {
    final saved = _box.get(_ordersKey);
    if (saved == null || saved.isEmpty) {
      return const [];
    }

    try {
      final list = (jsonDecode(saved) as List<dynamic>)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return const [];
    }
  }

  void addOrder(Order order) {
    final updated = [order, ...state.orders]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = state.copyWith(orders: updated);
    _persist(updated);
  }

  Future<void> simulateOrderProgress(
    String orderId, {
    Duration readyDelay = const Duration(seconds: 5),
    Duration completedDelay = const Duration(seconds: 8),
  }) {
    final completer = Completer<void>();

    late final Timer readyTimer;
    readyTimer = Timer(readyDelay, () {
      _updateOrderStatus(orderId, 'ready');
      _simulationTimers.remove(readyTimer);

      late final Timer completedTimer;
      completedTimer = Timer(completedDelay, () {
        _updateOrderStatus(orderId, 'completed');
        _simulationTimers.remove(completedTimer);
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
      _simulationTimers.add(completedTimer);
    });

    _simulationTimers.add(readyTimer);
    return completer.future;
  }

  void markAsRated(String orderId) {
    final updated = state.orders
        .map((order) =>
            order.id == orderId ? order.copyWith(isRated: true) : order)
        .toList();
    state = state.copyWith(orders: updated);
    _persist(updated);
  }

  void _updateOrderStatus(String orderId, String status) {
    final hasOrder = state.orders.any((order) => order.id == orderId);
    if (!hasOrder) {
      return;
    }

    final updated = state.orders
        .map((order) =>
            order.id == orderId ? order.copyWith(status: status) : order)
        .toList();

    state = state.copyWith(orders: updated);
    _persist(updated);
  }

  void _persist(List<Order> orders) {
    final payload = jsonEncode(orders.map((order) => order.toJson()).toList());
    _box.put(_ordersKey, payload);
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, OrdersState>(
  OrdersNotifier.new,
);

final orderProgressSimulationEnabledProvider = Provider<bool>((ref) => true);

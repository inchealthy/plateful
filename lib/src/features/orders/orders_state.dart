import '../../common/domain/entities/order.dart';

class OrdersState {
  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
  });

  final List<Order> orders;
  final bool isLoading;

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

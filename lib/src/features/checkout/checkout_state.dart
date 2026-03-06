class CheckoutState {
  const CheckoutState({
    this.isNow = true,
    this.scheduledTime,
    this.isLoading = false,
    this.orderPlaced = false,
  });

  final bool isNow;
  final DateTime? scheduledTime;
  final bool isLoading;
  final bool orderPlaced;

  CheckoutState copyWith({
    bool? isNow,
    DateTime? scheduledTime,
    bool clearScheduledTime = false,
    bool? isLoading,
    bool? orderPlaced,
  }) {
    return CheckoutState(
      isNow: isNow ?? this.isNow,
      scheduledTime:
          clearScheduledTime ? null : (scheduledTime ?? this.scheduledTime),
      isLoading: isLoading ?? this.isLoading,
      orderPlaced: orderPlaced ?? this.orderPlaced,
    );
  }
}

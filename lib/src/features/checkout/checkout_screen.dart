import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../common/components/app_button.dart';
import '../cart/cart_controller.dart';
import 'checkout_controller.dart';
import 'checkout_state.dart';
import 'widgets/order_success_dialog.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  Future<void> _pickTime(
    BuildContext context,
    CheckoutController controller,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) {
      return;
    }

    final now = DateTime.now();
    controller.setScheduledTime(
      DateTime(now.year, now.month, now.day, picked.hour, picked.minute),
    );
  }

  String _formatTime(BuildContext context, DateTime time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: time.hour, minute: time.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CheckoutState>(checkoutProvider, (prev, next) {
      final wasPlaced = prev?.orderPlaced ?? false;
      if (wasPlaced || !next.orderPlaced || !mounted) {
        return;
      }

      ref.read(checkoutProvider.notifier).consumeOrderPlaced();
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const OrderSuccessDialog(),
      );
    });

    final cart = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final controller = ref.read(checkoutProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cart.items.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🧺', style: TextStyle(fontSize: 56.sp)),
                    SizedBox(height: 8.h),
                    Text(
                      'Your cart is empty',
                      style: AppTextStyles.heading3,
                    ),
                    SizedBox(height: 16.h),
                    AppButton(
                      label: 'Back to Home',
                      onPressed: () => context.go('/shell/home'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _SectionCard(
                    title: 'Order Summary',
                    child: Column(
                      children: cart.items
                          .map(
                            (cartItem) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 2.h),
                                    child: Text(
                                      cartItem.item.emoji,
                                      style: TextStyle(fontSize: 20.sp),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cartItem.item.name,
                                          style: AppTextStyles.body,
                                        ),
                                        if (cartItem.selectedAddOns
                                            .isNotEmpty) ...[
                                          SizedBox(height: 2.h),
                                          Text(
                                            cartItem.selectedAddOns
                                                .map((a) => a.name)
                                                .join(', '),
                                            style: AppTextStyles.label
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '×${cartItem.quantity}',
                                    style: AppTextStyles.label.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '\$${cartItem.lineTotal.toStringAsFixed(2)}',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _SectionCard(
                    title: 'Pickup Location',
                    child: Row(
                      children: [
                        Text('📍', style: TextStyle(fontSize: 20.sp)),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            cart.restaurantName ?? '',
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _SectionCard(
                    title: 'Pickup Time',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Now'),
                              icon: Icon(Icons.flash_on),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Schedule'),
                              icon: Icon(Icons.schedule),
                            ),
                          ],
                          selected: {checkoutState.isNow},
                          onSelectionChanged: (value) {
                            controller.togglePickupMode(value.first);
                          },
                        ),
                        if (!checkoutState.isNow) ...[
                          SizedBox(height: 12.h),
                          OutlinedButton.icon(
                            key: const Key('schedule-time-button'),
                            onPressed: () => _pickTime(context, controller),
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              checkoutState.scheduledTime == null
                                  ? 'Pick a time'
                                  : _formatTime(
                                      context,
                                      checkoutState.scheduledTime!,
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _SectionCard(
                    title: 'Price Summary',
                    child: Column(
                      children: [
                        _PriceRow(
                          label: 'Subtotal',
                          value: '\$${cart.subtotal.toStringAsFixed(2)}',
                        ),
                        SizedBox(height: 6.h),
                        _PriceRow(
                          label: 'Tax (8%)',
                          value: '\$${cart.tax.toStringAsFixed(2)}',
                        ),
                        SizedBox(height: 8.h),
                        const Divider(color: AppColors.border),
                        SizedBox(height: 8.h),
                        _PriceRow(
                          label: 'Total',
                          value: '\$${cart.total.toStringAsFixed(2)}',
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: AppButton(
                  key: const Key('place-order-button'),
                  label: checkoutState.isLoading
                      ? 'Placing Order...'
                      : 'Place Order',
                  isLoading: checkoutState.isLoading,
                  onPressed: checkoutState.isLoading
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          controller.placeOrder();
                        },
                ),
              ),
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final base = bold ? AppTextStyles.heading3 : AppTextStyles.body;
    return Row(
      children: [
        Text(label, style: base),
        const Spacer(),
        Text(
          value,
          style: base.copyWith(
            color: bold ? AppColors.primary : AppColors.textPrimary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../common/components/app_button.dart';
import '../../../common/domain/entities/order.dart';
import 'order_status_badge.dart';
import 'order_view_utils.dart';

class OrderDetailSheet extends StatelessWidget {
  const OrderDetailSheet({
    required this.order,
    super.key,
  });

  final Order order;

  @override
  Widget build(BuildContext context) {
    final subtotal = order.items.fold<double>(
      0,
      (sum, item) => sum + (item.item.price * item.quantity),
    );
    final tax = subtotal * 0.08;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderRestaurantEmoji(order),
                    style: TextStyle(fontSize: 32.sp),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.restaurantName,
                          style: AppTextStyles.heading3,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Order #${orderShortId(order)} · ${orderDateLabel(order.createdAt)}',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              const Divider(color: AppColors.border),
              ...order.items.map(
                (cartItem) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    children: [
                      Text(
                        cartItem.item.emoji,
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          cartItem.item.name,
                          style: AppTextStyles.body,
                        ),
                      ),
                      Text(
                        '×${cartItem.quantity}',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        '\$${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: AppColors.border),
              _PriceRow(
                label: 'Subtotal',
                value: '\$${subtotal.toStringAsFixed(2)}',
              ),
              SizedBox(height: 6.h),
              _PriceRow(
                label: 'Tax (8%)',
                value: '\$${tax.toStringAsFixed(2)}',
              ),
              SizedBox(height: 6.h),
              _PriceRow(
                label: 'Total',
                value: '\$${order.total.toStringAsFixed(2)}',
                bold: true,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Text('Status:', style: AppTextStyles.body),
                  const Spacer(),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              if (order.status == 'completed' && !order.isRated) ...[
                SizedBox(height: 16.h),
                AppButton(
                  key: Key('leave-feedback-${order.id}'),
                  label: '⭐ Leave Feedback',
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/feedback/${order.id}');
                  },
                ),
              ],
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
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
    final style = bold ? AppTextStyles.heading3 : AppTextStyles.body;

    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(
          value,
          style: style.copyWith(
            color: bold ? AppColors.primary : AppColors.textPrimary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

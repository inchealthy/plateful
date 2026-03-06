import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../common/components/app_button.dart';
import '../cart_state.dart';

class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({
    required this.cartState,
    required this.onCheckout,
    super.key,
  });

  final CartState cartState;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(
            label: 'Subtotal',
            value: '\$${cartState.subtotal.toStringAsFixed(2)}',
          ),
          SizedBox(height: 6.h),
          _SummaryRow(
            label: 'Tax (8%)',
            value: '\$${cartState.tax.toStringAsFixed(2)}',
          ),
          SizedBox(height: 8.h),
          const Divider(color: AppColors.border),
          SizedBox(height: 8.h),
          _SummaryRow(
            label: 'Total',
            value: '\$${cartState.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          SizedBox(height: 12.h),
          AppButton(
            label: 'Proceed to Checkout',
            onPressed: onCheckout,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal ? AppTextStyles.heading3 : AppTextStyles.body;

    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(
          value,
          style: style.copyWith(
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

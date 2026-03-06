import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../common/components/app_button.dart';

class OrderSuccessDialog extends StatelessWidget {
  const OrderSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('✅', style: TextStyle(fontSize: 64.sp)),
          SizedBox(height: 12.h),
          Text('Order Placed!', style: AppTextStyles.heading2),
          SizedBox(height: 8.h),
          Text(
            'Your order is being prepared.\nEst. ready: 15–20 minutes',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 20.h),
          AppButton(
            key: const Key('track-order-button'),
            label: 'Track Order',
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/shell/orders');
            },
          ),
        ],
      ),
    );
  }
}

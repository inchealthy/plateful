import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/themes/app_text_styles.dart';
import 'order_view_utils.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    required this.status,
    super.key,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: orderStatusBackground(status),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        orderStatusLabel(status),
        style: AppTextStyles.label.copyWith(
          color: orderStatusTextColor(status),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

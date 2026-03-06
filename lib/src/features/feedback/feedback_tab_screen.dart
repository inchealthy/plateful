import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../orders/orders_controller.dart';
import 'widgets/unrated_order_card.dart';

class FeedbackTabScreen extends ConsumerWidget {
  const FeedbackTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    final unratedOrders = ordersState.orders
        .where((order) => order.status == 'completed' && !order.isRated)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: unratedOrders.isEmpty
          ? const _AllCaughtUpWidget()
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: unratedOrders.length,
              itemBuilder: (context, index) {
                final order = unratedOrders[index];
                return UnratedOrderCard(
                  order: order,
                  onTap: () => context.push('/feedback/${order.id}'),
                );
              },
            ),
    );
  }
}

class _AllCaughtUpWidget extends StatelessWidget {
  const _AllCaughtUpWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎉', style: TextStyle(fontSize: 64.sp)),
            SizedBox(height: 8.h),
            Text('All caught up!', style: AppTextStyles.heading3),
            SizedBox(height: 6.h),
            Text(
              'No pending reviews',
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

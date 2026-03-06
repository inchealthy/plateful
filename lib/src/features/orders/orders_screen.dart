import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/themes/app_text_styles.dart';
import 'orders_controller.dart';
import 'widgets/order_card.dart';
import 'widgets/order_detail_sheet.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: ordersState.orders.isEmpty
          ? const _EmptyOrdersWidget()
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: ordersState.orders.length,
              itemBuilder: (context, index) {
                final order = ordersState.orders[index];
                return OrderCard(
                  order: order,
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => OrderDetailSheet(order: order),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _EmptyOrdersWidget extends StatelessWidget {
  const _EmptyOrdersWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📋', style: TextStyle(fontSize: 56.sp)),
            SizedBox(height: 8.h),
            Text('No orders yet', style: AppTextStyles.heading3),
            SizedBox(height: 6.h),
            Text(
              'Start by browsing restaurants',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

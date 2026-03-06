import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../common/components/app_button.dart';
import '../orders/widgets/order_view_utils.dart';
import 'feedback_controller.dart';
import 'feedback_state.dart';
import 'widgets/dimension_rating_row.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  void _showSuccessModal() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('✅', style: TextStyle(fontSize: 64.sp)),
            SizedBox(height: 12.h),
            Text('Thank You!', style: AppTextStyles.heading2),
            SizedBox(height: 8.h),
            Text(
              'Your feedback helps us serve you better.',
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            AppButton(
              label: 'Done',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderId = GoRouterState.of(context).pathParameters['orderId'];
    if (orderId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Leave Feedback')),
        body: const Center(child: Text('Order not found.')),
      );
    }

    ref.listen<FeedbackState>(feedbackProvider(orderId), (previous, next) {
      final wasSubmitted = previous?.submitted ?? false;
      if (!wasSubmitted && next.submitted) {
        _showSuccessModal();
      }
    });

    final state = ref.watch(feedbackProvider(orderId));
    final controller = ref.read(feedbackProvider(orderId).notifier);
    final order = state.order;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Leave Feedback'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Feedback'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.restaurantName, style: AppTextStyles.heading3),
                  SizedBox(height: 4.h),
                  Text(
                    'Order #${orderShortId(order)} · ${orderDateLabel(order.createdAt)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    orderItemsSummary(order),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            DimensionRatingRow(
              dimensionKey: 'overall',
              label: 'Overall Experience',
              rating: state.overallRating,
              onRatingChanged: (value) =>
                  controller.setRating(FeedbackDimension.overall, value),
            ),
            SizedBox(height: 20.h),
            DimensionRatingRow(
              dimensionKey: 'foodQuality',
              label: 'Food Quality',
              rating: state.foodQualityRating,
              onRatingChanged: (value) =>
                  controller.setRating(FeedbackDimension.foodQuality, value),
            ),
            SizedBox(height: 20.h),
            DimensionRatingRow(
              dimensionKey: 'portionSize',
              label: 'Portion Size',
              rating: state.portionSizeRating,
              onRatingChanged: (value) =>
                  controller.setRating(FeedbackDimension.portionSize, value),
            ),
            SizedBox(height: 20.h),
            DimensionRatingRow(
              dimensionKey: 'serviceSpeed',
              label: 'Service Speed',
              rating: state.serviceSpeedRating,
              onRatingChanged: (value) =>
                  controller.setRating(FeedbackDimension.serviceSpeed, value),
            ),
            SizedBox(height: 24.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tell us more (optional)',
                style:
                    AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              key: const Key('feedback-comment-field'),
              maxLines: 4,
              maxLength: 500,
              onChanged: controller.setComment,
              decoration: const InputDecoration(
                hintText: 'What did you like or dislike? Any suggestions?',
                hintStyle: TextStyle(color: AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: AppButton(
            key: const Key('feedback-submit-button'),
            label: state.isSubmitting ? 'Submitting...' : 'Submit Feedback',
            isLoading: state.isSubmitting,
            onPressed: state.canSubmit && !state.isSubmitting
                ? controller.submit
                : null,
          ),
        ),
      ),
    );
  }
}

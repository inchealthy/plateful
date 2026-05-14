import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../common/components/app_button.dart';
import '../../common/domain/entities/feedback_model.dart';
import '../home/home_controller.dart';
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
  // Local state used only in restaurant mode
  int _overallRating = 0;
  int _foodRating = 0;
  int _serviceRating = 0;
  int _recommendRating = 0;
  String _comment = '';
  bool _isSubmitting = false;

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

  // ── Order-based feedback ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final params = GoRouterState.of(context).pathParameters;
    final restaurantId = params['restaurantId'];
    final orderId = params['orderId'];

    if (restaurantId != null) {
      return _buildRestaurantFeedback(restaurantId);
    }
    if (orderId != null) {
      return _buildOrderFeedback(orderId);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Leave Feedback')),
      body: const Center(child: Text('Feedback target not found.')),
    );
  }

  // ── Restaurant mode ───────────────────────────────────────────────────────

  Widget _buildRestaurantFeedback(String restaurantId) {
    final homeState = ref.watch(homeProvider);
    final restaurant =
        homeState.allRestaurants.where((r) => r.id == restaurantId).firstOrNull;

    bool canSubmit = _overallRating > 0 &&
        _foodRating > 0 &&
        _serviceRating > 0 &&
        _recommendRating > 0;

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
              child: Row(
                children: [
                  Text(restaurant?.emoji ?? '🍽️',
                      style: TextStyle(fontSize: 32.sp)),
                  SizedBox(width: 12.w),
                  Text(restaurant?.name ?? '', style: AppTextStyles.heading3),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            ..._ratingRows(
              overallRating: _overallRating,
              foodRating: _foodRating,
              serviceRating: _serviceRating,
              recommendRating: _recommendRating,
              onOverall: (v) => setState(() => _overallRating = v),
              onFood: (v) => setState(() => _foodRating = v),
              onService: (v) => setState(() => _serviceRating = v),
              onRecommend: (v) => setState(() => _recommendRating = v),
            ),
            SizedBox(height: 24.h),
            _commentField(onChanged: (v) => setState(() => _comment = v)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: AppButton(
            label: _isSubmitting ? 'Submitting...' : 'Submit Feedback',
            isLoading: _isSubmitting,
            onPressed: canSubmit && !_isSubmitting
                ? () => _submitRestaurant(restaurantId)
                : null,
          ),
        ),
      ),
    );
  }

  Future<void> _submitRestaurant(String restaurantId) async {
    setState(() => _isSubmitting = true);

    final feedback = FeedbackModel(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      restaurantId: restaurantId,
      overallRating: _overallRating,
      foodRating: _foodRating,
      serviceRating: _serviceRating,
      recommendRating: _recommendRating,
      comment: _comment.trim().isEmpty ? null : _comment.trim(),
      submittedAt: DateTime.now(),
    );

    _persistFeedback(feedback);
    setState(() => _isSubmitting = false);
    _showSuccessModal();
  }

  // ── Order mode ────────────────────────────────────────────────────────────

  Widget _buildOrderFeedback(String orderId) {
    ref.listen<FeedbackState>(feedbackProvider(orderId), (previous, next) {
      if (!(previous?.submitted ?? false) && next.submitted) {
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
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    orderItemsSummary(order),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            ..._ratingRows(
              overallRating: state.overallRating,
              foodRating: state.foodRating,
              serviceRating: state.serviceRating,
              recommendRating: state.recommendRating,
              onOverall: (v) =>
                  controller.setRating(FeedbackDimension.overall, v),
              onFood: (v) => controller.setRating(FeedbackDimension.food, v),
              onService: (v) =>
                  controller.setRating(FeedbackDimension.service, v),
              onRecommend: (v) =>
                  controller.setRating(FeedbackDimension.recommend, v),
            ),
            SizedBox(height: 24.h),
            _commentField(onChanged: controller.setComment),
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

  // ── Shared helpers ────────────────────────────────────────────────────────

  List<Widget> _ratingRows({
    required int overallRating,
    required int foodRating,
    required int serviceRating,
    required int recommendRating,
    required ValueChanged<int> onOverall,
    required ValueChanged<int> onFood,
    required ValueChanged<int> onService,
    required ValueChanged<int> onRecommend,
  }) {
    return [
      DimensionRatingRow(
        dimensionKey: 'overall',
        label: 'Overall Experience',
        rating: overallRating,
        onRatingChanged: onOverall,
      ),
      SizedBox(height: 20.h),
      DimensionRatingRow(
        dimensionKey: 'food',
        label: 'Food Quality',
        rating: foodRating,
        onRatingChanged: onFood,
      ),
      SizedBox(height: 20.h),
      DimensionRatingRow(
        dimensionKey: 'service',
        label: 'Service',
        rating: serviceRating,
        onRatingChanged: onService,
      ),
      SizedBox(height: 20.h),
      DimensionRatingRow(
        dimensionKey: 'recommend',
        label: 'Would you recommend this place to other people?',
        rating: recommendRating,
        onRatingChanged: onRecommend,
      ),
    ];
  }

  Widget _commentField({required ValueChanged<String> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us more (optional)',
          style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        TextField(
          key: const Key('feedback-comment-field'),
          maxLines: 4,
          maxLength: 500,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'What did you like or dislike? Any suggestions?',
            hintStyle: TextStyle(color: AppColors.textHint),
          ),
        ),
      ],
    );
  }

  void _persistFeedback(FeedbackModel feedback) {
    const boxName = 'feedbacks';
    const feedbacksKey = 'feedbacks_list';
    final box = Hive.box<String>(boxName);
    final raw = box.get(feedbacksKey);

    final list = <FeedbackModel>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final value in decoded) {
          list.add(FeedbackModel.fromJson(value as Map<String, dynamic>));
        }
      } catch (_) {}
    }

    list.add(feedback);
    box.put(feedbacksKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}

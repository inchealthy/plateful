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
import 'widgets/dimension_rating_row.dart';

class RestaurantFeedbackScreen extends ConsumerStatefulWidget {
  const RestaurantFeedbackScreen({super.key});

  @override
  ConsumerState<RestaurantFeedbackScreen> createState() =>
      _RestaurantFeedbackScreenState();
}

class _RestaurantFeedbackScreenState
    extends ConsumerState<RestaurantFeedbackScreen> {
  int _overallRating = 0;
  int _foodRating = 0;
  int _serviceRating = 0;
  int _recommendRating = 0;
  String _comment = '';
  bool _isSubmitting = false;

  bool get _canSubmit =>
      _overallRating > 0 &&
      _foodRating > 0 &&
      _serviceRating > 0 &&
      _recommendRating > 0;

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

  Future<void> _submit(String restaurantId) async {
    if (!_canSubmit) return;
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
    box.put(feedbacksKey,
        jsonEncode(list.map((e) => e.toJson()).toList()));

    setState(() => _isSubmitting = false);
    _showSuccessModal();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantId =
        GoRouterState.of(context).pathParameters['restaurantId'];

    if (restaurantId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Leave Feedback')),
        body: const Center(child: Text('Restaurant not found.')),
      );
    }

    final homeState = ref.watch(homeProvider);
    final restaurant = homeState.allRestaurants
        .where((r) => r.id == restaurantId)
        .firstOrNull;

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
                  Text(
                    restaurant?.emoji ?? '🍽️',
                    style: TextStyle(fontSize: 32.sp),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    restaurant?.name ?? '',
                    style: AppTextStyles.heading3,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            DimensionRatingRow(
              dimensionKey: 'overall',
              label: 'Overall Experience',
              rating: _overallRating,
              onRatingChanged: (v) => setState(() => _overallRating = v),
            ),
            SizedBox(height: 20.h),
            DimensionRatingRow(
              dimensionKey: 'food',
              label: 'Food Quality',
              rating: _foodRating,
              onRatingChanged: (v) => setState(() => _foodRating = v),
            ),
            SizedBox(height: 20.h),
            DimensionRatingRow(
              dimensionKey: 'service',
              label: 'Service',
              rating: _serviceRating,
              onRatingChanged: (v) => setState(() => _serviceRating = v),
            ),
            SizedBox(height: 20.h),
            DimensionRatingRow(
              dimensionKey: 'recommend',
              label: 'Would you recommend this place to other people?',
              rating: _recommendRating,
              onRatingChanged: (v) => setState(() => _recommendRating = v),
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
              maxLines: 4,
              maxLength: 500,
              onChanged: (v) => setState(() => _comment = v),
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
            label: _isSubmitting ? 'Submitting...' : 'Submit Feedback',
            isLoading: _isSubmitting,
            onPressed: _canSubmit && !_isSubmitting
                ? () => _submit(restaurantId)
                : null,
          ),
        ),
      ),
    );
  }
}

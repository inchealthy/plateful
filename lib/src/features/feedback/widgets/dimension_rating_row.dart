import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';

class DimensionRatingRow extends StatelessWidget {
  const DimensionRatingRow({
    required this.dimensionKey,
    required this.label,
    required this.rating,
    required this.onRatingChanged,
    super.key,
  });

  final String dimensionKey;
  final String label;
  final int rating;
  final ValueChanged<int> onRatingChanged;

  static const _ratingText = {
    1: 'Poor 😞',
    2: 'Fair 😐',
    3: 'Good 🙂',
    4: 'Great 😊',
    5: 'Excellent! 🤩',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final isActive = starValue <= rating;
            return GestureDetector(
              key: Key('feedback-star-$dimensionKey-$starValue'),
              onTap: () {
                HapticFeedback.lightImpact();
                onRatingChanged(starValue);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: Icon(
                  Icons.star_rounded,
                  size: 40.sp,
                  color: isActive
                      ? Colors.amber
                      : Colors.grey.withValues(alpha: 0.3),
                ).animate(target: isActive ? 1 : 0).scale(
                    begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
              ),
            );
          }),
        ),
        SizedBox(height: 6.h),
        Center(
          child: Text(
            rating > 0 ? _ratingText[rating]! : '',
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

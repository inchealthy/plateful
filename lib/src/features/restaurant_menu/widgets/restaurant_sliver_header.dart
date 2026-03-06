import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../common/domain/entities/restaurant.dart';

class RestaurantSliverHeader extends StatelessWidget {
  const RestaurantSliverHeader({
    required this.restaurant,
    super.key,
  });

  final Restaurant restaurant;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.success;
      case 'closed':
        return AppColors.error;
      case 'busy':
        return AppColors.warning;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final collapsedHeight = kToolbarHeight + topPadding;

    return SliverAppBar(
      expandedHeight: 220.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: Padding(
        padding: EdgeInsets.all(8.r),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.chevron_left),
            color: AppColors.primary,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 56.w, bottom: 16.h),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final showCollapsedTitle = constraints.maxHeight <=
                collapsedHeight + 8.h;

            if (!showCollapsedTitle) {
              return const SizedBox.shrink();
            }

            return Text(
              restaurant.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading3.copyWith(color: Colors.white),
            );
          },
        ),
        background: LayoutBuilder(
          builder: (context, constraints) {
            final showExpandedContent = constraints.maxHeight >
                collapsedHeight + 42.h;

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: showExpandedContent
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 24.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              restaurant.emoji,
                              style: TextStyle(fontSize: 48.sp),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              restaurant.name,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.heading2.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: [
                                _StatChip(
                                  label:
                                      '⭐ ${restaurant.rating.toStringAsFixed(1)}',
                                ),
                                _StatChip(label: '🕐 ${restaurant.hours}'),
                                _StatChip(
                                  label:
                                      '📍 ${restaurant.distanceMiles.toStringAsFixed(1)} mi',
                                ),
                                _StatusBadge(
                                  label: restaurant.status,
                                  color: _statusColor(restaurant.status),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Text(
        '${label[0].toUpperCase()}${label.substring(1)}',
        style: AppTextStyles.label.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

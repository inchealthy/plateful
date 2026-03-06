import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';

class MenuCategoryTabsHeader extends StatelessWidget {
  const MenuCategoryTabsHeader({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _MenuCategoryTabsDelegate(
        categories: categories,
        selectedCategory: selectedCategory,
        onCategorySelected: onCategorySelected,
      ),
    );
  }
}

class _MenuCategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  const _MenuCategoryTabsDelegate({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  double get minExtent => 56.h;

  @override
  double get maxExtent => 56.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      alignment: Alignment.centerLeft,
      child: ListView.separated(
        key: const Key('menu-category-tabs'),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = category == selectedCategory;
          return InkWell(
            onTap: () => onCategorySelected(category),
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    category,
                    style: AppTextStyles.body.copyWith(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 3.h,
                    width: 28.w,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemCount: categories.length,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _MenuCategoryTabsDelegate oldDelegate) {
    return oldDelegate.categories != categories ||
        oldDelegate.selectedCategory != selectedCategory;
  }
}

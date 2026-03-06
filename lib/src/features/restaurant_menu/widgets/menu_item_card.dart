import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../common/domain/entities/menu_item.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    required this.item,
    required this.quantity,
    required this.isOrderingEnabled,
    required this.onTap,
    required this.onIncrementTap,
    required this.onDecrementTap,
    super.key,
  });

  final MenuItem item;
  final int quantity;
  final bool isOrderingEnabled;
  final VoidCallback onTap;
  final VoidCallback onIncrementTap;
  final VoidCallback onDecrementTap;

  Color _categoryColor(String category) {
    switch (category) {
      case 'Breakfast':
        return const Color(0xFFFFF3E0);
      case 'Lunch':
        return const Color(0xFFE8F5E9);
      case 'Dinner':
        return const Color(0xFFE3F2FD);
      case 'Snacks':
        return const Color(0xFFFFF8E1);
      case 'Beverages':
        return const Color(0xFFF3E5F5);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  List<String> _dietaryIcons(List<String> tags) {
    final icons = <String>[];
    if (tags.contains('Vegan')) {
      icons.add('🌱');
    }
    if (tags.contains('Gluten-Free')) {
      icons.add('🌾');
    }
    if (tags.contains('Spicy')) {
      icons.add('🌶');
    }
    return icons;
  }

  @override
  Widget build(BuildContext context) {
    final dietaryIcons = _dietaryIcons(item.dietaryTags);

    return GestureDetector(
      key: Key('menu-item-${item.id}'),
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90.w,
              height: 90.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _categoryColor(item.category),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(item.emoji, style: TextStyle(fontSize: 36.sp)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      if (dietaryIcons.isNotEmpty)
                        Text(
                          dietaryIcons.join(' '),
                          style: TextStyle(fontSize: 14.sp),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.calories.toInt()} cal · ${item.protein.toInt()}g protein',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      quantity <= 0
                          ? _AddButton(
                              menuItemId: item.id,
                              enabled: isOrderingEnabled,
                              onTap: onIncrementTap,
                            )
                          : _InlineStepper(
                              menuItemId: item.id,
                              quantity: quantity,
                              enabled: isOrderingEnabled,
                              onIncrementTap: onIncrementTap,
                              onDecrementTap: onDecrementTap,
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.menuItemId,
    required this.enabled,
    required this.onTap,
  });

  final String menuItemId;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('menu-item-add-$menuItemId'),
      onTap: () {
        if (!enabled) {
          return;
        }
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32.w,
        height: 32.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          '+',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            height: 0.95,
          ),
        ),
      ),
    );
  }
}

class _InlineStepper extends StatelessWidget {
  const _InlineStepper({
    required this.menuItemId,
    required this.quantity,
    required this.enabled,
    required this.onIncrementTap,
    required this.onDecrementTap,
  });

  final String menuItemId;
  final int quantity;
  final bool enabled;
  final VoidCallback onIncrementTap;
  final VoidCallback onDecrementTap;

  @override
  Widget build(BuildContext context) {
    final actionColor = enabled ? AppColors.primary : AppColors.textHint;

    return Container(
      key: Key('menu-item-stepper-$menuItemId'),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            key: Key('menu-item-minus-$menuItemId'),
            onTap: () {
              if (!enabled) {
                return;
              }
              HapticFeedback.lightImpact();
              onDecrementTap();
            },
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(
                Icons.remove,
                size: 16.sp,
                color: actionColor,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            '$quantity',
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.w700,
              color: enabled ? AppColors.textPrimary : AppColors.textHint,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            key: Key('menu-item-plus-$menuItemId'),
            onTap: () {
              if (!enabled) {
                return;
              }
              HapticFeedback.lightImpact();
              onIncrementTap();
            },
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(
                Icons.add,
                size: 16.sp,
                color: actionColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

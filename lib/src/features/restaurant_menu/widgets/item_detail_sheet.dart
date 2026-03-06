import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../common/components/app_button.dart';
import '../../../common/domain/entities/cart_item.dart';
import '../../../common/domain/entities/menu_item.dart';
import '../../cart/cart_controller.dart';

class ItemDetailSheet extends ConsumerStatefulWidget {
  const ItemDetailSheet({
    required this.item,
    required this.restaurantName,
    required this.isRestaurantClosed,
    super.key,
  });

  final MenuItem item;
  final String restaurantName;
  final bool isRestaurantClosed;

  @override
  ConsumerState<ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends ConsumerState<ItemDetailSheet> {
  int _quantity = 1;

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

  Future<void> _handleAddToCart() async {
    if (widget.isRestaurantClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text('Restaurant is closed. Ordering unavailable.'),
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 90.h),
        ),
      );
      return;
    }

    final cartState = ref.read(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    if (cartState.items.isNotEmpty &&
        cartNotifier.hasConflictWithRestaurant(widget.item.restaurantId)) {
      await _showConflictDialog(
          cartState.restaurantName ?? 'another restaurant');
      return;
    }

    cartNotifier.addItem(
      CartItem(item: widget.item, quantity: _quantity),
      restaurantName: widget.restaurantName,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _showConflictDialog(String previousRestaurantName) async {
    final cartNotifier = ref.read(cartProvider.notifier);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Replace Cart?'),
          content: Text(
            'Your cart has items from $previousRestaurantName. '
            'Clear cart and add from ${widget.restaurantName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cartNotifier.clearAndAdd(
                  CartItem(item: widget.item, quantity: _quantity),
                  restaurantName: widget.restaurantName,
                );
                Navigator.of(dialogContext).pop();
                if (!mounted) {
                  return;
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'Clear & Add',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final total = item.price * _quantity;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              width: 120.w,
              height: 120.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _categoryColor(item.category),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(item.emoji, style: TextStyle(fontSize: 56.sp)),
            ),
            SizedBox(height: 12.h),
            Text(item.name, style: AppTextStyles.heading2),
            SizedBox(height: 4.h),
            Text(
              item.description,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 14.h),
            const Divider(color: AppColors.border),
            SizedBox(height: 12.h),
            Row(
              children: [
                _NutritionBox(
                  value: '${item.calories.toInt()}',
                  label: 'Calories',
                ),
                SizedBox(width: 8.w),
                _NutritionBox(value: '${item.carbs.toInt()}g', label: 'Carbs'),
                SizedBox(width: 8.w),
                _NutritionBox(
                  value: '${item.protein.toInt()}g',
                  label: 'Protein',
                ),
                SizedBox(width: 8.w),
                _NutritionBox(value: '${item.fat.toInt()}g', label: 'Fat'),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(color: AppColors.border),
            if (item.allergens.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Allergens',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: item.allergens
                    .map(
                      (allergen) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.warning),
                        ),
                        child: Text(
                          allergen,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (item.dietaryTags.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dietary',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: item.dietaryTags
                    .map((tag) => _DietaryBadge(tag: tag))
                    .toList(),
              ),
            ],
            SizedBox(height: 12.h),
            const Divider(color: AppColors.border),
            SizedBox(height: 10.h),
            Row(
              children: [
                _QtyButton(
                  icon: Icons.remove,
                  onTap:
                      _quantity > 1 ? () => setState(() => _quantity--) : null,
                ),
                SizedBox(width: 14.w),
                Text('$_quantity', style: AppTextStyles.heading3),
                SizedBox(width: 14.w),
                _QtyButton(
                  icon: Icons.add,
                  onTap: () => setState(() => _quantity++),
                ),
                const Spacer(),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style:
                      AppTextStyles.heading2.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            AppButton(
              key: Key('item-sheet-add-button-${item.id}'),
              label: 'Add to Cart',
              onPressed: _handleAddToCart,
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}

class _NutritionBox extends StatelessWidget {
  const _NutritionBox({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FB),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style:
                  AppTextStyles.label.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _DietaryBadge extends StatelessWidget {
  const _DietaryBadge({required this.tag});

  final String tag;

  String _iconForTag(String value) {
    switch (value) {
      case 'Vegan':
        return '🌱';
      case 'Gluten-Free':
        return '🌾';
      case 'Spicy':
        return '🌶';
      default:
        return '🏷';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        '${_iconForTag(tag)} $tag',
        style: AppTextStyles.label,
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border),
          color: onTap == null ? const Color(0xFFF5F5F5) : Colors.white,
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: onTap == null ? AppColors.textHint : AppColors.textPrimary,
        ),
      ),
    );
  }
}

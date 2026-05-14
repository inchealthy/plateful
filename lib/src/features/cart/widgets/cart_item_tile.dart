import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../common/domain/entities/cart_item.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    required this.cartItem,
    required this.restaurantName,
    required this.onQtyChanged,
    required this.onRemove,
    super.key,
  });

  final CartItem cartItem;
  final String restaurantName;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onRemove;

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

  @override
  Widget build(BuildContext context) {
    final item = cartItem.item;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _categoryColor(item.category),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(item.emoji, style: TextStyle(fontSize: 26.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
                if (cartItem.selectedAddOns.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    cartItem.selectedAddOns.map((a) => a.name).join(', '),
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 4.h),
                Text(
                  restaurantName,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  _StepperButton(
                    key: Key('cart-minus-${item.id}'),
                    icon: Icons.remove,
                    onTap: () => onQtyChanged(cartItem.quantity - 1),
                  ),
                  SizedBox(width: 8.w),
                  Text('${cartItem.quantity}', style: AppTextStyles.body),
                  SizedBox(width: 8.w),
                  _StepperButton(
                    key: Key('cart-plus-${item.id}'),
                    icon: Icons.add,
                    onTap: () => onQtyChanged(cartItem.quantity + 1),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                '\$${cartItem.lineTotal.toStringAsFixed(2)}',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          IconButton(
            key: Key('cart-delete-${item.id}'),
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18.sp),
      ),
    );
  }
}

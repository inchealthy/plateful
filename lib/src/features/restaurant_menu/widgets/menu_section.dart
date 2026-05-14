import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/themes/app_text_styles.dart';
import '../../../common/domain/entities/menu_item.dart';
import 'menu_item_card.dart';

class MenuSection extends StatelessWidget {
  const MenuSection({
    required this.selectedCategory,
    required this.items,
    required this.itemQuantityOf,
    required this.isOrderingEnabled,
    required this.onTapItem,
    required this.onIncrementItem,
    required this.onDecrementItem,
    this.selectedAllergens = const {},
    super.key,
  });

  final String selectedCategory;
  final List<MenuItem> items;
  final int Function(String menuItemId) itemQuantityOf;
  final bool isOrderingEnabled;
  final ValueChanged<MenuItem> onTapItem;
  final ValueChanged<MenuItem> onIncrementItem;
  final ValueChanged<MenuItem> onDecrementItem;
  final Set<String> selectedAllergens;

  bool _hasAllergenWarning(MenuItem item) =>
      selectedAllergens.isNotEmpty &&
      item.allergens.any(selectedAllergens.contains);

  static const _baseOrder = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Beverages',
  ];

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'No menu items found',
            style: AppTextStyles.body,
          ),
        ),
      );
    }

    final children = <Widget>[];

    if (selectedCategory == 'All') {
      final byCategory = <String, List<MenuItem>>{};
      for (final item in items) {
        byCategory.putIfAbsent(item.category, () => []).add(item);
      }

      final categories = [
        ..._baseOrder.where(byCategory.containsKey),
        ...byCategory.keys.where((e) => !_baseOrder.contains(e)).toList()
          ..sort(),
      ];

      for (final category in categories) {
        final sectionItems = byCategory[category] ?? const [];
        if (sectionItems.isEmpty) {
          continue;
        }

        children.add(
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
            child: Text(
              '${sectionItems.first.emoji} $category (${sectionItems.length})',
              style: AppTextStyles.heading3,
            ),
          ),
        );

        for (final item in sectionItems) {
          children.add(
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: MenuItemCard(
                item: item,
                quantity: itemQuantityOf(item.id),
                isOrderingEnabled: isOrderingEnabled,
                hasAllergenWarning: _hasAllergenWarning(item),
                onTap: () => onTapItem(item),
                onIncrementTap: () => onIncrementItem(item),
                onDecrementTap: () => onDecrementItem(item),
              ),
            ),
          );
        }
      }
    } else {
      for (final item in items) {
        children.add(
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: MenuItemCard(
              item: item,
              quantity: itemQuantityOf(item.id),
              isOrderingEnabled: isOrderingEnabled,
              onTap: () => onTapItem(item),
              onIncrementTap: () => onIncrementItem(item),
              onDecrementTap: () => onDecrementItem(item),
            ),
          ),
        );
      }
    }

    return SliverList(delegate: SliverChildListDelegate(children));
  }
}

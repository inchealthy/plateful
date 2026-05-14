import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../common/domain/entities/add_on.dart';
import '../../../common/domain/entities/menu_item.dart';

class ItemDetailSheet extends ConsumerStatefulWidget {
  const ItemDetailSheet({
    required this.item,
    required this.restaurantName,
    required this.isRestaurantClosed,
    this.addOnGroups = const [],
    this.selectedAllergens = const {},
    super.key,
  });

  final MenuItem item;
  final String restaurantName;
  final bool isRestaurantClosed;
  final List<AddOnGroup> addOnGroups;
  final Set<String> selectedAllergens;

  @override
  ConsumerState<ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends ConsumerState<ItemDetailSheet> {
  bool _showNutritionDetail = false;
  final Set<int> _deselectedIngredients = {};
  final Set<String> _selectedAddOns = {};

  bool _hasIngredients() => widget.item.ingredients.isNotEmpty;

  double _addOnTotal(double Function(AddOnOption) pick) => widget.addOnGroups
      .expand((g) => g.options)
      .where((o) => _selectedAddOns.contains(o.id))
      .fold(0.0, (s, o) => s + pick(o));

  double _activeCalories() {
    final base = _hasIngredients()
        ? widget.item.ingredients
            .asMap()
            .entries
            .where((e) => !_deselectedIngredients.contains(e.key))
            .fold(0.0, (s, e) => s + e.value.calories)
        : widget.item.calories;
    return base + _addOnTotal((o) => o.calories);
  }

  double _activeCarbs() {
    final base = _hasIngredients()
        ? widget.item.ingredients
            .asMap()
            .entries
            .where((e) => !_deselectedIngredients.contains(e.key))
            .fold(0.0, (s, e) => s + e.value.carbs)
        : widget.item.carbs;
    return base + _addOnTotal((o) => o.carbs);
  }

  double _activeProtein() {
    final base = _hasIngredients()
        ? widget.item.ingredients
            .asMap()
            .entries
            .where((e) => !_deselectedIngredients.contains(e.key))
            .fold(0.0, (s, e) => s + e.value.protein)
        : widget.item.protein;
    return base + _addOnTotal((o) => o.protein);
  }

  double _activeFat() {
    final base = _hasIngredients()
        ? widget.item.ingredients
            .asMap()
            .entries
            .where((e) => !_deselectedIngredients.contains(e.key))
            .fold(0.0, (s, e) => s + e.value.fat)
        : widget.item.fat;
    return base + _addOnTotal((o) => o.fat);
  }

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

  List<String> get _matchedAllergens => widget.item.allergens
      .where(widget.selectedAllergens.contains)
      .toList();

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final matched = _matchedAllergens;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.92),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Padding(
              padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // scrollable body
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _categoryColor(item.category),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(item.emoji,
                            style: TextStyle(fontSize: 56.sp)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Center(
                        child:
                            Text(item.name, style: AppTextStyles.heading2)),
                    SizedBox(height: 4.h),
                    Center(
                      child: Text(
                        item.description,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    if (matched.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.warning),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('⚠️', style: TextStyle(fontSize: 14.sp)),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Contains allergens you\'ve flagged: ${matched.join(', ')}',
                                style: AppTextStyles.label.copyWith(
                                  color: const Color(0xFF7C4700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 14.h),
                    const Divider(color: AppColors.border),
                    SizedBox(height: 12.h),

                    // nutrition
                    Row(
                      children: [
                        _NutritionBox(
                            value: '${_activeCalories().toInt()}',
                            label: 'Calories'),
                        SizedBox(width: 8.w),
                        _NutritionBox(
                            value: '${_activeCarbs().toInt()}g',
                            label: 'Carbs'),
                        SizedBox(width: 8.w),
                        _NutritionBox(
                            value: '${_activeProtein().toInt()}g',
                            label: 'Protein'),
                        SizedBox(width: 8.w),
                        _NutritionBox(
                            value: '${_activeFat().toInt()}g', label: 'Fat'),
                      ],
                    ),

                    if (item.allergens.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      const Divider(color: AppColors.border),
                      SizedBox(height: 12.h),
                      Text(
                        'Allergens',
                        style: AppTextStyles.label
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: item.allergens
                            .map(
                              (allergen) => Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border:
                                      Border.all(color: AppColors.warning),
                                ),
                                child: Text(
                                  allergen,
                                  style: AppTextStyles.label
                                      .copyWith(color: AppColors.warning),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    if (item.dietaryTags.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      if (item.allergens.isEmpty)
                        const Divider(color: AppColors.border),
                      SizedBox(height: item.allergens.isEmpty ? 12.h : 0),
                      Text(
                        'Dietary',
                        style: AppTextStyles.label
                            .copyWith(fontWeight: FontWeight.w700),
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

                    if (item.ingredients.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      const Divider(color: AppColors.border),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Ingredient',
                              style: AppTextStyles.label
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() =>
                                _showNutritionDetail = !_showNutritionDetail),
                            child: Text(
                              _showNutritionDetail
                                  ? 'Hide Detail'
                                  : 'Show Detail',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          children: [
                            SizedBox(width: 28.w),
                            Expanded(
                              flex: 5,
                              child: Text(
                                'Ingredient',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.textHint,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            _NutriHeader('Cal'),
                            if (_showNutritionDetail) ...[
                              _NutriHeader('Carb'),
                              _NutriHeader('Pro'),
                              _NutriHeader('Fat'),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            for (int i = 0;
                                i < item.ingredients.length;
                                i++) ...[
                              if (i > 0)
                                Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: AppColors.border),
                              _IngredientRow(
                                ingredient: item.ingredients[i],
                                showDetail: _showNutritionDetail,
                                isSelected:
                                    !_deselectedIngredients.contains(i),
                                onToggle: () => setState(() {
                                  if (_deselectedIngredients.contains(i)) {
                                    _deselectedIngredients.remove(i);
                                  } else {
                                    _deselectedIngredients.add(i);
                                  }
                                }),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    if (widget.addOnGroups.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      const Divider(color: AppColors.border),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Add-Ons',
                              style: AppTextStyles.label
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (!_hasIngredients())
                            GestureDetector(
                              onTap: () => setState(() =>
                                  _showNutritionDetail = !_showNutritionDetail),
                              child: Text(
                                _showNutritionDetail
                                    ? 'Hide Detail'
                                    : 'Show Detail',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          children: [
                            SizedBox(width: 28.w),
                            const Expanded(flex: 5, child: SizedBox()),
                            _NutriHeader('Cal'),
                            if (_showNutritionDetail) ...[
                              _NutriHeader('Carb'),
                              _NutriHeader('Pro'),
                              _NutriHeader('Fat'),
                            ],
                          ],
                        ),
                      ),
                      for (int gi = 0;
                          gi < widget.addOnGroups.length;
                          gi++) ...[
                        if (widget.addOnGroups.length > 1) ...[
                          if (gi > 0) SizedBox(height: 10.h),
                          Text(
                            widget.addOnGroups[gi].name,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6.h),
                        ],
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < widget.addOnGroups[gi].options.length;
                                  i++) ...[
                                if (i > 0)
                                  Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.border),
                                _AddOnRow(
                                  option: widget.addOnGroups[gi].options[i],
                                  showDetail: _showNutritionDetail,
                                  isSelected: _selectedAddOns.contains(
                                      widget.addOnGroups[gi].options[i].id),
                                  onToggle: () => setState(() {
                                    final id =
                                        widget.addOnGroups[gi].options[i].id;
                                    if (_selectedAddOns.contains(id)) {
                                      _selectedAddOns.remove(id);
                                    } else {
                                      _selectedAddOns.add(id);
                                    }
                                  }),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            //
            // // fixed footer
            // Container(
            //   padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     border: Border(
            //         top: BorderSide(color: AppColors.border, width: 1)),
            //   ),
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Row(
            //         children: [
            //           _QtyButton(
            //             icon: Icons.remove,
            //             onTap: _quantity > 1
            //                 ? () => setState(() => _quantity--)
            //                 : null,
            //           ),
            //           SizedBox(width: 14.w),
            //           Text('$_quantity', style: AppTextStyles.heading3),
            //           SizedBox(width: 14.w),
            //           _QtyButton(
            //             icon: Icons.add,
            //             onTap: () => setState(() => _quantity++),
            //           ),
            //           const Spacer(),
            //           Text(
            //             '\$${_total.toStringAsFixed(2)}',
            //             style: AppTextStyles.heading2
            //                 .copyWith(color: AppColors.primary),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 12.h),
            //       AppButton(
            //         key: Key('item-sheet-add-button-${item.id}'),
            //         label: _canAddToCart
            //             ? 'Add to Cart'
            //             : 'Select required options',
            //         onPressed: _canAddToCart ? _handleAddToCart : null,
            //       ),
            //       SizedBox(
            //           height: MediaQuery.of(context).viewInsets.bottom),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// ── Add-on row ────────────────────────────────────────────────────────────────

class _AddOnRow extends StatelessWidget {
  const _AddOnRow({
    required this.option,
    required this.isSelected,
    required this.onToggle,
    this.showDetail = false,
  });

  final AddOnOption option;
  final bool isSelected;
  final VoidCallback onToggle;
  final bool showDetail;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isSelected ? AppColors.textPrimary : AppColors.textHint;
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                activeColor: AppColors.primary,
                side: BorderSide(color: AppColors.border, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r)),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 5,
              child: Text(
                option.name,
                style: AppTextStyles.label.copyWith(color: textColor),
              ),
            ),
            _cell('${option.calories.toInt()}', textColor),
            if (showDetail) ...[
              _cell('${option.carbs.toInt()}g', textColor),
              _cell('${option.protein.toInt()}g', textColor),
              _cell('${option.fat.toInt()}g', textColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cell(String text, Color color) {
    return SizedBox(
      width: 36.w,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _NutriHeader extends StatelessWidget {
  const _NutriHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36.w,
      child: Text(
        label,
        textAlign: TextAlign.right,
        style: AppTextStyles.label.copyWith(
          color: AppColors.textHint,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.ingredient,
    required this.isSelected,
    required this.onToggle,
    this.showDetail = false,
  });
  final Ingredient ingredient;
  final bool isSelected;
  final VoidCallback onToggle;
  final bool showDetail;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isSelected ? AppColors.textPrimary : AppColors.textHint;
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                activeColor: AppColors.primary,
                side: BorderSide(color: AppColors.border, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r)),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 5,
              child: Text(
                ingredient.name,
                style: AppTextStyles.label.copyWith(color: textColor),
              ),
            ),
            _cell('${ingredient.calories.toInt()}', textColor),
            if (showDetail) ...[
              _cell('${ingredient.carbs.toInt()}g', textColor),
              _cell('${ingredient.protein.toInt()}g', textColor),
              _cell('${ingredient.fat.toInt()}g', textColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cell(String text, Color color) {
    return SizedBox(
      width: 36.w,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }
}

class _NutritionBox extends StatelessWidget {
  const _NutritionBox({required this.value, required this.label});

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
            Text(value,
                style:
                    AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 2.h),
            Text(label,
                style: AppTextStyles.label
                    .copyWith(color: AppColors.textSecondary)),
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
      child: Text('${_iconForTag(tag)} $tag', style: AppTextStyles.label),
    );
  }
}


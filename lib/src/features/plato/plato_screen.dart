import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../common/components/app_chip.dart';
import '../../common/domain/entities/add_on.dart';
import '../home/home_controller.dart';
import '../restaurant_menu/widgets/item_detail_sheet.dart';
import 'plato_controller.dart';
import 'plato_state.dart';


class PlatoScreen extends ConsumerStatefulWidget {
  const PlatoScreen({super.key});

  @override
  ConsumerState<PlatoScreen> createState() => _PlatoScreenState();
}

class _PlatoScreenState extends ConsumerState<PlatoScreen> {
  static const _dietaryPrefs = [
    'Vegan 🌱',
    'Vegetarian',
    'Gluten-Free',
    'Halal',
    'No Spicy',
    'Dairy-Free',
  ];

  static const _commonAllergens = [
    'Gluten',
    'Dairy',
    'Eggs',
    'Peanuts',
    'Tree Nuts',
    'Soy',
    'Wheat',
    'Fish',
    'Shellfish',
    'Sesame',
    'Mustard',
    'Sulphites',
  ];

  late final TextEditingController _freeTextController;

  @override
  void initState() {
    super.initState();
    _freeTextController = TextEditingController();
  }

  @override
  void dispose() {
    _freeTextController.dispose();
    super.dispose();
  }

  Future<void> _openItemDetail(PlatoRecommendation rec) async {
    final raw = await rootBundle.loadString('assets/jsons/addons.json');
    final groups = (jsonDecode(raw) as List)
        .map((e) => AddOnGroup.fromJson(e as Map<String, dynamic>))
        .where((g) => g.applicableItemIds.contains(rec.item.id))
        .toList();

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemDetailSheet(
        item: rec.item,
        restaurantName: rec.restaurantName,
        isRestaurantClosed: rec.isRestaurantClosed,
        addOnGroups: groups,
        selectedAllergens: ref.read(platoProvider).selectedAllergens,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(platoProvider);
    final controller = ref.read(platoProvider.notifier);
    final homeState = ref.watch(homeProvider);
    final locationName = homeState.selectedLocation?.name ?? 'All locations';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(locationName),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status == PlatoStatus.loading)
                    const _LoadingView()
                  else ...[
                    SizedBox(height: 20.h),
                    _PrefsSection(
                      title: 'Dietary Preferences',
                      items: _dietaryPrefs,
                      selected: state.selectedDietaryPrefs,
                      onTap: (p) {
                        HapticFeedback.lightImpact();
                        controller.togglePref(p);
                      },
                    ),
                    SizedBox(height: 16.h),
                    _PrefsSection(
                      title: 'Allergens to Avoid',
                      items: _commonAllergens,
                      selected: state.selectedAllergens,
                      onTap: (a) {
                        HapticFeedback.lightImpact();
                        controller.toggleAllergen(a);
                      },
                    ),
                    SizedBox(height: 16.h),
                    _FreeTextSection(
                      textController: _freeTextController,
                      onChanged: controller.updateFreeText,
                    ),
                    SizedBox(height: 28.h),
                    if (state.status == PlatoStatus.results) ...[
                      _ResultsHeader(),
                      SizedBox(height: 12.h),
                      ...state.recommendations.map(
                        (rec) => Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: _RecommendationCard(
                            rec: rec,
                            onViewDetails: () => _openItemDetail(rec),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      _ActionButton(
                        label: 'Try Again',
                        icon: Icons.refresh,
                        onPressed: controller.reset,
                        outlined: true,
                      ),
                    ] else if (state.status == PlatoStatus.empty) ...[
                      _EmptyView(onReset: controller.reset),
                    ] else if (state.status == PlatoStatus.error) ...[
                      _ErrorView(
                        message: state.errorMessage,
                        onRetry: controller.findMyMeal,
                        onReset: controller.reset,
                      ),
                    ] else ...[
                      _ActionButton(
                        label: 'Find My Meal',
                        icon: Icons.auto_awesome,
                        onPressed: controller.findMyMeal,
                      ),
                    ],
                  ],
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String locationName) {
    return SliverAppBar(
      expandedHeight: 156.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.smart_toy_rounded,
                      color: Colors.white, size: 28.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Nutrition AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on,
                        size: 12.sp,
                        color: Colors.white.withValues(alpha: 0.8)),
                    SizedBox(width: 3.w),
                    Text(
                      locationName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.gradientEnd,
    );
  }
}

// ── Preference chips ──────────────────────────────────────────────────────────

class _PrefsSection extends StatelessWidget {
  const _PrefsSection({
    required this.title,
    required this.items,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final List<String> items;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading3),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: items
              .map((item) => AppChip(
                    label: item,
                    isSelected: selected.contains(item),
                    onTap: () => onTap(item),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ── Free text ─────────────────────────────────────────────────────────────────

class _FreeTextSection extends StatelessWidget {
  const _FreeTextSection({
    required this.textController,
    required this.onChanged,
  });

  final TextEditingController textController;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Anything else?', style: AppTextStyles.heading3),
        SizedBox(height: 10.h),
        TextField(
          controller: textController,
          onChanged: onChanged,
          maxLines: 3,
          textInputAction: TextInputAction.done,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText:
                'e.g. "I want something light and under 500 calories"',
            hintStyle:
                AppTextStyles.body.copyWith(color: AppColors.textHint),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 52.h,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r)),
          ),
          icon: Icon(icon, size: 18.sp),
          label: Text(label,
              style:
                  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd]),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r)),
          ),
          icon: Icon(icon, color: Colors.white, size: 18.sp),
          label: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatefulWidget {
  const _LoadingView();

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _anim,
            child: Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy_rounded,
                  color: AppColors.primary, size: 38.sp),
            ),
          ),
          SizedBox(height: 20.h),
          Text('Finding your meal…',
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.heading3.copyWith(color: AppColors.primary)),
          SizedBox(height: 8.h),
          Text(
            'Finding the best matches for you…',
            textAlign: TextAlign.center,
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Empty ─────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onReset});
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Text('😕', style: TextStyle(fontSize: 48.sp)),
        SizedBox(height: 16.h),
        Text('No matches found', style: AppTextStyles.heading3),
        SizedBox(height: 8.h),
        Text(
          'No menu items at this location match your preferences and allergen filters. Try relaxing a few.',
          textAlign: TextAlign.center,
          style:
              AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 24.h),
        _ActionButton(
            label: 'Try Again',
            icon: Icons.refresh,
            onPressed: onReset,
            outlined: true),
      ],
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onReset,
  });

  final String? message;
  final VoidCallback onRetry;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
            border:
                Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline,
                      color: AppColors.error, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('Something went wrong',
                      style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.error)),
                ],
              ),
              if (message != null) ...[
                SizedBox(height: 6.h),
                Text(
                  message!,
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _ActionButton(
            label: 'Retry', icon: Icons.refresh, onPressed: onRetry),
        SizedBox(height: 10.h),
        _ActionButton(
            label: 'Start Over',
            icon: Icons.arrow_back,
            onPressed: onReset,
            outlined: true),
      ],
    );
  }
}

// ── Results header ────────────────────────────────────────────────────────────

class _ResultsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.auto_awesome, color: AppColors.primary, size: 18.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text('Meals matching your filters',
              style: AppTextStyles.heading3),
        ),
      ],
    );
  }
}

// ── Recommendation card ───────────────────────────────────────────────────────

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.rec, required this.onViewDetails});
  final PlatoRecommendation rec;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(rec.item.emoji,
                      style: TextStyle(fontSize: 32.sp)),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec.item.name,
                        style:
                            AppTextStyles.heading3.copyWith(fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${rec.restaurantEmoji} ${rec.restaurantName}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Text(
                            '\$${rec.item.price.toStringAsFixed(2)}',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${rec.item.calories.toInt()} kcal',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (rec.reason != null)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
              child: Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 13.sp, color: AppColors.primary),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        rec.reason!,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onViewDetails,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                ),
                icon: Icon(Icons.restaurant_menu_outlined, size: 16.sp),
                label: const Text('View Details'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

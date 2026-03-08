import 'package:flutter/material.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../common/components/app_search_bar.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.currentLocationName,
    required this.onChangeLocationTap,
    required this.selectedTabIndex,
    required this.onTabChanged,
    required this.onSearchChanged,
    super.key,
  });

  final String currentLocationName;
  final VoidCallback onChangeLocationTap;
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, topInset + 20, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  currentLocationName,
                  key: const Key('home-current-location-name'),
                  style: AppTextStyles.heading2.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.location_on, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          InkWell(
            key: const Key('home-change-location'),
            onTap: onChangeLocationTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Change my location',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          AppSearchBar(
            onChanged: onSearchChanged,
            hintText: 'What are you craving?',
            fillColor: Colors.white,
          ),
          const SizedBox(height: 12),
          _ViewToggle(selectedIndex: selectedTabIndex, onChanged: onTabChanged),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              key: const Key('home-toggle-list'),
              label: 'List',
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ToggleButton(
              key: const Key('home-toggle-map'),
              label: 'Map',
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : Colors.white70,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../common/components/app_chip.dart';

class FilterChipsBar extends StatelessWidget {
  const FilterChipsBar({
    required this.selectedFilter,
    required this.onFilterSelected,
    super.key,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  static const _filters = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Beverages',
    'Vegan',
    'Halal',
    'Gluten-Free',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: _filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AppChip(
                  label: filter,
                  isSelected: selectedFilter == filter,
                  onTap: () => onFilterSelected(filter),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

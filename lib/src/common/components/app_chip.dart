import 'package:flutter/material.dart';

import '../../app/themes/app_colors.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}

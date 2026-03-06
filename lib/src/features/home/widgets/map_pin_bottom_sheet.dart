import 'package:flutter/material.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../common/domain/entities/restaurant.dart';

class MapPinBottomSheet extends StatelessWidget {
  const MapPinBottomSheet({
    required this.restaurant,
    required this.onViewMenu,
    super.key,
  });

  final Restaurant restaurant;
  final VoidCallback onViewMenu;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.success;
      case 'closed':
        return AppColors.error;
      case 'busy':
        return AppColors.warning;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(restaurant.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(restaurant.name, style: AppTextStyles.heading3),
                      const SizedBox(height: 2),
                      Text(
                        restaurant.cuisine,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              runSpacing: 6,
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(restaurant.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    restaurant.status[0].toUpperCase() +
                        restaurant.status.substring(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text('📍 ${restaurant.distanceMiles.toStringAsFixed(1)} mi'),
                Text('⭐ ${restaurant.rating.toStringAsFixed(1)}'),
                Text('🕐 ${restaurant.hours}'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewMenu,
                child: const Text('View Menu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

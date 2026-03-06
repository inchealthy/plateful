import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../common/components/app_chip.dart';
import 'profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const _dietaryPrefs = [
    'Vegan 🌱',
    'Vegetarian',
    'Gluten-Free',
    'Halal',
    'No Spicy',
    'Dairy-Free',
  ];

  late final TextEditingController _allergiesController;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(profileProvider).allergiesText;
    _allergiesController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    super.dispose();
  }

  String _initialsFromEmail(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) {
      return 'U';
    }
    if (local.length == 1) {
      return local.toUpperCase();
    }
    return '${local[0]}${local[1]}'.toUpperCase();
  }

  Future<void> _showSignOutDialog() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'This will clear all local data on this device. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true || !mounted) {
      return;
    }

    await ref.read(profileProvider.notifier).signOutAndClearAllLocalData();
    if (!mounted) {
      return;
    }
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final controller = ref.read(profileProvider.notifier);
    final email = controller.userEmail;

    if (_allergiesController.text != state.allergiesText) {
      _allergiesController.value = _allergiesController.value.copyWith(
        text: state.allergiesText,
        selection: TextSelection.collapsed(offset: state.allergiesText.length),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  _initialsFromEmail(email),
                  style: TextStyle(
                    fontSize: 32.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Center(child: Text(email, style: AppTextStyles.heading3)),
            SizedBox(height: 4.h),
            Center(
              child: Text(
                'Signed in locally',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text('Dietary Preferences', style: AppTextStyles.heading3),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _dietaryPrefs
                  .map(
                    (pref) => AppChip(
                      label: pref,
                      isSelected: state.selectedDietaryPrefs.contains(pref),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        controller.togglePref(pref);
                      },
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 20.h),
            Text('Allergies', style: AppTextStyles.heading3),
            SizedBox(height: 10.h),
            TextField(
              key: const Key('profile-allergies-field'),
              controller: _allergiesController,
              maxLines: 2,
              onChanged: controller.updateAllergies,
              decoration: const InputDecoration(
                hintText: 'e.g. peanuts, shellfish, tree nuts',
              ),
            ),
            SizedBox(height: 24.h),
            const Divider(color: AppColors.border),
            ListTile(
              leading: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Order History'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.go('/shell/orders'),
            ),
            const Divider(color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: _showSignOutDialog,
            ),
          ],
        ),
      ),
    );
  }
}

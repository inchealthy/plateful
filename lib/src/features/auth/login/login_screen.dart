import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../common/components/app_button.dart';
import 'login_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  Future<void> _signIn() async {
    final success = await ref.read(loginProvider.notifier).signIn();
    if (!mounted || !success) {
      return;
    }
    context.go('/shell/home');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final controller = ref.read(loginProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              Image.asset(
                'assets/images/NutriHero_NutriHero - HorizontalLogo.png',
                height: 72.h,
              ),
              SizedBox(height: 8.h),
              Text(
                'Campus Dining Made Easy',
                style:
                    AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 48.h),
              TextField(
                key: const Key('login-email-field'),
                onChanged: controller.updateEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                key: const Key('login-password-field'),
                onChanged: controller.updatePassword,
                obscureText: !state.passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      state.passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              ),
              if (state.errorMessage != null) ...[
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.errorMessage!,
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.error),
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              AppButton(
                key: const Key('login-signin-button'),
                label: 'Sign In',
                isLoading: state.isLoading,
                onPressed: state.isLoading ? null : _signIn,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'or',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 16.h),
              Tooltip(
                message: 'Coming soon',
                child: OutlinedButton.icon(
                  icon: const Text(
                    'G',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  label: const Text(
                    'Sign in with Google',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 52.h),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

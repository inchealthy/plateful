import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login/login_screen.dart';
import '../features/auth/login/splash_screen.dart';
import '../features/auth/login/auth_session.dart';
import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/feedback/feedback_screen.dart';
import '../features/feedback/feedback_tab_screen.dart';
import '../features/home/home_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/restaurant_menu/restaurant_menu_screen.dart';
import 'route_enums.dart';
import 'shell_scaffold.dart';

final router = GoRouter(
  initialLocation: AppRoute.splash.path,
  redirect: (context, state) {
    final isLoggedIn = AuthSessionStore.read().isLoggedIn;
    final location = state.matchedLocation;
    return resolveAppRedirect(location: location, isLoggedIn: isLoggedIn);
  },
  routes: [
    GoRoute(
      path: AppRoute.splash.path,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoute.login.path,
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellScaffold(shell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.home.path,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.orders.path,
              builder: (context, state) => const OrdersScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.feedback.path,
              builder: (context, state) => const FeedbackTabScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.profile.path,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoute.restaurantMenu.path,
      pageBuilder: (context, state) => buildSlideUpPage(
        key: state.pageKey,
        child: const RestaurantMenuScreen(),
      ),
    ),
    GoRoute(
      path: AppRoute.cart.path,
      pageBuilder: (context, state) => buildSlideUpPage(
        key: state.pageKey,
        child: const CartScreen(),
      ),
    ),
    GoRoute(
      path: AppRoute.checkout.path,
      pageBuilder: (context, state) => buildSlideUpPage(
        key: state.pageKey,
        child: const CheckoutScreen(),
      ),
    ),
    GoRoute(
      path: AppRoute.feedbackForm.path,
      pageBuilder: (context, state) => buildSlideUpPage(
        key: state.pageKey,
        child: const FeedbackScreen(),
      ),
    ),
  ],
);

String? resolveAppRedirect({
  required String location,
  required bool isLoggedIn,
}) {
  final isSplash = location == AppRoute.splash.path;
  final isLogin = location == AppRoute.login.path;

  if (isSplash) {
    return null;
  }
  if (!isLoggedIn && !isLogin) {
    return AppRoute.login.path;
  }
  if (isLoggedIn && isLogin) {
    return AppRoute.home.path;
  }
  return null;
}

CustomTransitionPage<void> buildSlideUpPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      );
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

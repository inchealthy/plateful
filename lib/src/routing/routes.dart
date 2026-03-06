import 'package:go_router/go_router.dart';

import '../features/auth/login/login_screen.dart';
import '../features/auth/login/splash_screen.dart';
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
      builder: (context, state) => const RestaurantMenuScreen(),
    ),
    GoRoute(
      path: AppRoute.cart.path,
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: AppRoute.checkout.path,
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: AppRoute.feedbackForm.path,
      builder: (context, state) => const FeedbackScreen(),
    ),
  ],
);

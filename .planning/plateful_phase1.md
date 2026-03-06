# Plateful — Phase 1: Foundation + Navigation Shell
> Read `plateful_prd_final.md` first for full context. This file scopes Phase 1 only.

---

## Goal
Runnable app with correct folder structure, theme, all routes stubbed, bottom nav working. No real UI yet — just the skeleton that everything else builds on.

---

## What to Build

### 1. Flutter Project
- `flutter create plateful --org com.plateful`
- Dart SDK constraint: `>=3.0.0 <4.0.0`
- Flutter SDK: `>=3.28.8`

### 2. pubspec.yaml — add all packages
```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  go_router: ^14.0.0
  hive_flutter: ^1.1.0
  flutter_map: ^7.0.0
  latlong2: ^0.9.0
  geolocator: ^12.0.0
  permission_handler: ^11.0.0
  cached_network_image: ^3.3.1
  flutter_screenutil: ^5.9.0
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0

assets:
  - assets/jsons/
```

### 3. AppTheme — `lib/src/app/themes/`

**`app_colors.dart`:**
```dart
class AppColors {
  static const primary = Color(0xFF667EEA);
  static const primaryDark = Color(0xFF5568D3);
  static const gradientStart = Color(0xFF667EEA);
  static const gradientEnd = Color(0xFF764BA2);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF222222);
  static const textSecondary = Color(0xFF666666);
  static const textHint = Color(0xFF999999);
  static const border = Color(0xFFE0E0E0);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFF44336);
  static const warning = Color(0xFFFF9800);
}
```

**`app_sizes.dart`:** spacing constants `xs=4, sm=8, md=12, lg=16, xl=20, xxl=24`

**`app_text_styles.dart`:** heading1 (24px bold), heading2 (20px bold), heading3 (17px semibold), body (15px), caption (13px), label (12px) — all using system font, color `AppColors.textPrimary`

**`app_theme.dart`:** `ThemeData.light()` with:
- `colorScheme.primary = AppColors.primary`
- `scaffoldBackgroundColor = AppColors.background`
- `appBarTheme`: white bg, no elevation, `AppColors.textPrimary` title style, back button color primary
- `cardTheme`: white, radius 12, elevation 0, border `AppColors.border`
- `elevatedButtonTheme`: radius 12, primary bg, white text, height 52
- `inputDecorationTheme`: radius 12, filled `AppColors.background`, no border by default, focused border primary

### 4. Routing — `lib/src/routing/`

**`route_enums.dart`:**
```dart
enum AppRoute {
  splash,
  login,
  home,
  orders,
  feedback,
  profile,
  restaurantMenu,
  cart,
  checkout,
  feedbackForm,
}

extension AppRouteExt on AppRoute {
  String get path => switch (this) {
    AppRoute.splash         => '/splash',
    AppRoute.login          => '/login',
    AppRoute.home           => '/shell/home',
    AppRoute.orders         => '/shell/orders',
    AppRoute.feedback       => '/shell/feedback',
    AppRoute.profile        => '/shell/profile',
    AppRoute.restaurantMenu => '/restaurant/:restaurantId',
    AppRoute.cart           => '/cart',
    AppRoute.checkout       => '/checkout',
    AppRoute.feedbackForm   => '/feedback/:orderId',
  };
}
```

**`shell_scaffold.dart`:**
- `StatefulWidget` wrapping `Scaffold`
- `body: child` (active tab screen)
- `BottomNavigationBar` with 4 items: Home (house icon) · Orders (receipt icon) · Feedback (chat icon) · Profile (person icon)
- `selectedItemColor: AppColors.primary`
- `type: BottomNavigationBarType.fixed`
- On tap: `context.go(destinationPath)` — NOT push

**`routes.dart`:**
```dart
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: ...SplashScreen),
    GoRoute(path: '/login',  builder: ...LoginScreen),
    StatefulShellRoute.indexedStack(
      builder: (ctx, state, shell) => ShellScaffold(shell: shell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/shell/home', builder: ...HomeScreen)]),
        StatefulShellBranch(routes: [GoRoute(path: '/shell/orders', builder: ...OrdersScreen)]),
        StatefulShellBranch(routes: [GoRoute(path: '/shell/feedback', builder: ...FeedbackTabScreen)]),
        StatefulShellBranch(routes: [GoRoute(path: '/shell/profile', builder: ...ProfileScreen)]),
      ],
    ),
    GoRoute(path: '/restaurant/:restaurantId', builder: ...RestaurantMenuScreen),
    GoRoute(path: '/cart', builder: ...CartScreen),
    GoRoute(path: '/checkout', builder: ...CheckoutScreen),
    GoRoute(path: '/feedback/:orderId', builder: ...FeedbackScreen),
  ],
);
```

### 5. Stub All Screens
Every feature screen = minimal `Scaffold` with `AppBar(title: Text('ScreenName'))` + `Center(child: Text('TODO: ScreenName'))`.

Screens to stub:
- `SplashScreen` — redirects to `/shell/home` after 1.5s (use `Future.delayed`)
- `LoginScreen`
- `HomeScreen`
- `OrdersScreen`
- `FeedbackTabScreen`
- `ProfileScreen`
- `RestaurantMenuScreen` — reads `restaurantId` from `GoRouterState.pathParameters`
- `CartScreen`
- `CheckoutScreen`
- `FeedbackScreen` — reads `orderId` from `GoRouterState.pathParameters`

### 6. main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Firebase init — wrapped in try/catch for POC safety
  try { await Firebase.initializeApp(); } catch (_) {}
  runApp(const ProviderScope(child: PlatefulApp()));
}

class PlatefulApp extends StatelessWidget {
  const PlatefulApp({super.key});
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) => MaterialApp.router(
      title: 'Plateful',
      theme: AppTheme.light(),
      routerConfig: router,
    ),
  );
}
```

### 7. Common Components (skeletons only — full impl in later phases)
- `AppButton` — `ElevatedButton` wrapper, `label` + `onPressed` + `isLoading` params
- `AppChip` — `FilterChip` wrapper, `label` + `isSelected` + `onTap` params
- `AppSearchBar` — `TextField` with search prefix icon + clear suffix icon

---

## Acceptance Criteria
- [ ] App builds and runs on iOS + Android with no errors
- [ ] SplashScreen shows for 1.5s then navigates to HomeScreen stub
- [ ] All 4 bottom nav tabs tappable, each shows correct stub screen
- [ ] Navigating to `/restaurant/r1` shows RestaurantMenuScreen stub with `restaurantId = r1` printed
- [ ] AppTheme colors + button styles applied globally (verify on stub screens)
- [ ] No analysis warnings (`flutter analyze` clean)

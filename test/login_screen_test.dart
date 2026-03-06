import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plateful/src/app/themes/app_theme.dart';
import 'package:plateful/src/features/auth/login/auth_session.dart';
import 'package:plateful/src/features/auth/login/login_screen.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearAll);

  Future<void> pumpLoginApp(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/shell/home',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home Stub'))),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: router,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('sign in navigates to home and stores auth session',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await pumpLoginApp(tester, container);

    await tester.enterText(
      find.byKey(const Key('login-email-field')),
      'user@plateful.app',
    );
    await tester.enterText(
      find.byKey(const Key('login-password-field')),
      'secret',
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Home Stub'), findsOneWidget);

    final session = AuthSessionStore.read();
    expect(session.isLoggedIn, isTrue);
    expect(session.email, 'user@plateful.app');
  });
}

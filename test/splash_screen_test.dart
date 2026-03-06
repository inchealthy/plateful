import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plateful/src/features/auth/login/auth_session.dart';
import 'package:plateful/src/features/auth/login/splash_screen.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearAll);

  Future<void> pumpSplashApp(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Login Stub'))),
        ),
        GoRoute(
          path: '/shell/home',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home Stub'))),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
  }

  testWidgets('routes to login when auth session is missing', (tester) async {
    await pumpSplashApp(tester);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
    expect(find.text('Login Stub'), findsOneWidget);
  });

  testWidgets('routes to home when auth session is logged-in', (tester) async {
    AuthSessionStore.setLoggedIn(email: 'user@plateful.app');

    await pumpSplashApp(tester);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
    expect(find.text('Home Stub'), findsOneWidget);
  });
}

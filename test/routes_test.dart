import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plateful/src/routing/route_enums.dart';
import 'package:plateful/src/routing/routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('resolveAppRedirect enforces auth guard', () {
    expect(
      resolveAppRedirect(location: AppRoute.splash.path, isLoggedIn: false),
      isNull,
    );
    expect(
      resolveAppRedirect(location: AppRoute.home.path, isLoggedIn: false),
      AppRoute.login.path,
    );
    expect(
      resolveAppRedirect(location: AppRoute.login.path, isLoggedIn: true),
      AppRoute.home.path,
    );
    expect(
      resolveAppRedirect(location: AppRoute.orders.path, isLoggedIn: true),
      isNull,
    );
  });

  testWidgets('buildSlideUpPage uses SlideTransition', (tester) async {
    final page = buildSlideUpPage(
      key: const ValueKey('slide'),
      child: const Text('content'),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) => page.transitionsBuilder(
            context,
            const AlwaysStoppedAnimation<double>(0.5),
            const AlwaysStoppedAnimation<double>(0.0),
            page.child,
          ),
        ),
      ),
    );

    expect(find.byType(SlideTransition), findsOneWidget);
    expect(find.text('content'), findsOneWidget);
  });
}

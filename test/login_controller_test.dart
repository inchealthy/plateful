import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plateful/src/features/auth/login/auth_session.dart';
import 'package:plateful/src/features/auth/login/login_controller.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearAll);

  test('signIn validates fields and persists auth session', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(loginProvider.notifier);

    final invalid = await notifier.signIn();
    expect(invalid, isFalse);
    expect(container.read(loginProvider).errorMessage, isNotNull);

    notifier.updateEmail('user@plateful.app');
    notifier.updatePassword('secret');

    final success = await notifier.signIn();
    expect(success, isTrue);

    final session = AuthSessionStore.read();
    expect(session.isLoggedIn, isTrue);
    expect(session.email, 'user@plateful.app');
  });
}

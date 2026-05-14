import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:plateful/src/features/profile/profile_controller.dart';

import 'test_helpers/hive_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(HiveTestHelper.init);
  setUp(HiveTestHelper.clearAll);

  test('dietary prefs and allergens persist after reload', () async {
    final containerA = ProviderContainer();
    final notifier = containerA.read(profileProvider.notifier);

    notifier.togglePref('Vegan 🌱');
    notifier.toggleAllergen('Peanuts');

    containerA.dispose();

    final containerB = ProviderContainer();
    addTearDown(containerB.dispose);

    final state = containerB.read(profileProvider);
    expect(state.selectedDietaryPrefs.contains('Vegan 🌱'), isTrue);
    expect(state.selectedAllergens.contains('Peanuts'), isTrue);
  });

  test('signOut clears all local boxes', () async {
    await Hive.box<String>('cart').put('current_cart', '{}');
    await Hive.box<String>('orders').put('orders_list', '[]');
    await Hive.box<String>('feedbacks').put('feedbacks_list', '[]');
    await Hive.box<String>('profile').put(
      'profile_data',
      jsonEncode({
        'prefs': ['Vegan 🌱'],
        'allergens': ['Peanuts']
      }),
    );
    await Hive.box<String>('profile').put(
      'auth_session',
      jsonEncode({'isLoggedIn': true, 'email': 'user@plateful.app'}),
    );
    await Hive.box<bool>('meta').put('is_seeded', true);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(profileProvider.notifier)
        .signOutAndClearAllLocalData();

    expect(Hive.box<String>('cart').isEmpty, isTrue);
    expect(Hive.box<String>('orders').isEmpty, isTrue);
    expect(Hive.box<String>('feedbacks').isEmpty, isTrue);
    expect(Hive.box<String>('profile').isEmpty, isTrue);
    expect(Hive.box<bool>('meta').isEmpty, isTrue);
  });
}

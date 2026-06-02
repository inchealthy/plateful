import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../auth/login/auth_session.dart';
import 'profile_state.dart';

class ProfileController extends Notifier<ProfileState> {
  static const _boxName = 'profile';
  static const _profileKey = 'profile_data';

  late Box<String> _box;

  @override
  ProfileState build() {
    _box = Hive.box<String>(_boxName);
    final saved = _box.get(_profileKey);

    if (saved == null || saved.isEmpty) {
      return const ProfileState();
    }

    try {
      final json = jsonDecode(saved) as Map<String, dynamic>;
      return ProfileState(
        selectedDietaryPrefs:
            Set<String>.from(json['prefs'] as List? ?? const []),
        selectedAllergens:
            Set<String>.from(json['allergens'] as List? ?? const []),
      );
    } catch (_) {
      return const ProfileState();
    }
  }

  String get userEmail {
    final email = AuthSessionStore.read().email;
    return email == null || email.isEmpty ? 'user@nutrihero.app' : email;
  }

  void togglePref(String pref) {
    final updated = Set<String>.from(state.selectedDietaryPrefs);
    if (updated.contains(pref)) {
      updated.remove(pref);
    } else {
      updated.add(pref);
    }
    state = state.copyWith(selectedDietaryPrefs: updated);
    _persist();
  }

  void toggleAllergen(String allergen) {
    final updated = Set<String>.from(state.selectedAllergens);
    if (updated.contains(allergen)) {
      updated.remove(allergen);
    } else {
      updated.add(allergen);
    }
    state = state.copyWith(selectedAllergens: updated);
    _persist();
  }

  Future<void> signOutAndClearAllLocalData() async {
    await Hive.box<String>('cart').clear();
    await Hive.box<String>('orders').clear();
    await Hive.box<String>('feedbacks').clear();
    await Hive.box<String>('profile').clear();
    await Hive.box<bool>('meta').clear();

    state = const ProfileState();
  }

  Future<void> _persist() {
    return _box.put(
      _profileKey,
      jsonEncode({
        'prefs': state.selectedDietaryPrefs.toList(),
        'allergens': state.selectedAllergens.toList(),
      }),
    );
  }
}

final profileProvider = NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);

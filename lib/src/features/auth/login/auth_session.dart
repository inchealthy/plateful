import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class AuthSession {
  const AuthSession({
    required this.isLoggedIn,
    this.email,
  });

  final bool isLoggedIn;
  final String? email;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isLoggedIn': isLoggedIn,
      'email': email,
    };
  }
}

class AuthSessionStore {
  const AuthSessionStore._();

  static const profileBoxName = 'profile';
  static const authSessionKey = 'auth_session';

  static AuthSession read() {
    if (!Hive.isBoxOpen(profileBoxName)) {
      return const AuthSession(isLoggedIn: false);
    }

    final box = Hive.box<String>(profileBoxName);
    final raw = box.get(authSessionKey);
    if (raw == null || raw.isEmpty) {
      return const AuthSession(isLoggedIn: false);
    }

    try {
      return AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AuthSession(isLoggedIn: false);
    }
  }

  static void save(AuthSession session) {
    final box = Hive.box<String>(profileBoxName);
    box.put(authSessionKey, jsonEncode(session.toJson()));
  }

  static void setLoggedIn({required String email}) {
    save(AuthSession(isLoggedIn: true, email: email));
  }

  static void clear() {
    if (!Hive.isBoxOpen(profileBoxName)) {
      return;
    }
    Hive.box<String>(profileBoxName).delete(authSessionKey);
  }
}

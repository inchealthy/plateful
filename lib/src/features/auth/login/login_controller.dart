import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_session.dart';
import 'login_state.dart';

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() {
    return const LoginState();
  }

  void updateEmail(String value) {
    state = state.copyWith(
      email: value,
      clearError: true,
    );
  }

  void updatePassword(String value) {
    state = state.copyWith(
      password: value,
      clearError: true,
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(passwordVisible: !state.passwordVisible);
  }

  Future<bool> signIn() async {
    final email = state.email.trim();
    final password = state.password;

    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Email and password are required.',
      );
      return false;
    }

    if (!email.contains('@')) {
      state = state.copyWith(errorMessage: 'Please enter a valid email.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    await Future<void>.delayed(const Duration(milliseconds: 400));
    AuthSessionStore.setLoggedIn(email: email);

    state = state.copyWith(isLoading: false, clearError: true);
    return true;
  }
}

final loginProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);

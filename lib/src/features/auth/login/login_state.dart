class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
    this.passwordVisible = false,
  });

  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;
  final bool passwordVisible;

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? passwordVisible,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      passwordVisible: passwordVisible ?? this.passwordVisible,
    );
  }
}

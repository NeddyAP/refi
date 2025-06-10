import 'auth_user.dart';

/// Authentication state enumeration
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication state model
class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  /// Initial state
  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null,
        isLoading = false;

  /// Loading state
  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        errorMessage = null,
        isLoading = true;

  /// Authenticated state
  AuthState.authenticated(this.user)
      : status = AuthStatus.authenticated,
        errorMessage = null,
        isLoading = false;

  /// Unauthenticated state
  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = null,
        isLoading = false;

  /// Error state
  AuthState.error(this.errorMessage)
      : status = AuthStatus.error,
        user = null,
        isLoading = false;

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  /// Check if user is unauthenticated
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Check if there's an error
  bool get hasError => status == AuthStatus.error && errorMessage != null;

  /// Copy with new values
  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        user.hashCode ^
        errorMessage.hashCode ^
        isLoading.hashCode;
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: $user, errorMessage: $errorMessage, isLoading: $isLoading)';
  }
}

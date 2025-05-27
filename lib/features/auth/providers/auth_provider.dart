import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/auth_state.dart';
import '../models/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Authentication provider for state management
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  AuthState _state = const AuthState.initial();
  StreamSubscription<AuthUser?>? _authStateSubscription;

  AuthProvider(this._authRepository) {
    _initializeAuthState();
  }

  /// Current authentication state
  AuthState get state => _state;

  /// Current user
  AuthUser? get user => _state.user;

  /// Check if user is authenticated
  bool get isAuthenticated => _state.isAuthenticated;

  /// Check if user is loading
  bool get isLoading => _state.isLoading;

  /// Check if there's an error
  bool get hasError => _state.hasError;

  /// Error message
  String? get errorMessage => _state.errorMessage;

  /// Initialize authentication state
  void _initializeAuthState() {
    _setLoading();

    // Listen to auth state changes
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        if (user != null) {
          _setState(AuthState.authenticated(user));
        } else {
          _setState(const AuthState.unauthenticated());
        }
      },
      onError: (error) {
        _setState(AuthState.error(error.toString()));
      },
    );

    // Check for locally stored user data
    _checkLocalUser();
  }

  /// Check for locally stored user data
  Future<void> _checkLocalUser() async {
    try {
      final localUser = await _authRepository.getUserFromLocal();
      final currentUser = _authRepository.currentUser;

      // If we have a current Firebase user, use that
      if (currentUser != null) {
        _setState(AuthState.authenticated(currentUser));
      }
      // Otherwise, if we have local user data but no Firebase user, sign out
      else if (localUser != null) {
        await _authRepository.clearLocalUserData();
        _setState(const AuthState.unauthenticated());
      } else {
        _setState(const AuthState.unauthenticated());
      }
    } catch (e) {
      _setState(AuthState.error(e.toString()));
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setState(AuthState.authenticated(user));
    } catch (e) {
      // Extract the actual error message if it's wrapped in "Exception:"
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      _setState(AuthState.error(errorMessage));
    }
  }

  /// Create user with email and password
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _setLoading();
      final user = await _authRepository.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      _setState(AuthState.authenticated(user));
    } catch (e) {
      // Extract the actual error message if it's wrapped in "Exception:"
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      _setState(AuthState.error(errorMessage));
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _setLoading();
      final user = await _authRepository.signInWithGoogle();
      _setState(AuthState.authenticated(user));
    } catch (e) {
      // Extract the actual error message if it's wrapped in "Exception:"
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      _setState(AuthState.error(errorMessage));
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _setLoading();
      await _authRepository.sendPasswordResetEmail(email);
      _setState(const AuthState.unauthenticated());
    } catch (e) {
      _setState(AuthState.error(e.toString()));
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authRepository.sendEmailVerification();
    } catch (e) {
      _setState(AuthState.error(e.toString()));
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading();
      await _authRepository.signOut();
      _setState(const AuthState.unauthenticated());
    } catch (e) {
      _setState(AuthState.error(e.toString()));
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      _setLoading();
      await _authRepository.deleteAccount();
      _setState(const AuthState.unauthenticated());
    } catch (e) {
      _setState(AuthState.error(e.toString()));
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _setLoading();
      await _authRepository.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Get updated user
      final updatedUser = _authRepository.currentUser;
      if (updatedUser != null) {
        _setState(AuthState.authenticated(updatedUser));
      }
    } catch (e) {
      _setState(AuthState.error(e.toString()));
    }
  }

  /// Create request token for TMDB authentication
  Future<String> createRequestToken() async {
    try {
      _setLoading();
      final token = await _authRepository.createRequestToken();
      _setState(const AuthState.unauthenticated());
      return token;
    } catch (e) {
      _setState(AuthState.error(e.toString()));
      rethrow;
    }
  }

  /// Create session from approved request token
  Future<void> createSessionFromToken(String requestToken) async {
    try {
      _setLoading();
      final user = await _authRepository.createSessionFromToken(requestToken);
      _setState(AuthState.authenticated(user));
    } catch (e) {
      _setState(AuthState.error(e.toString()));
    }
  }

  /// Create guest session
  Future<void> createGuestSession() async {
    try {
      _setLoading();
      final user = await _authRepository.createGuestSession();
      _setState(AuthState.authenticated(user));
    } catch (e) {
      _setState(AuthState.error(e.toString()));
    }
  }

  /// Clear error state
  void clearError() {
    if (_state.hasError) {
      _setState(const AuthState.unauthenticated());
    }
  }

  /// Set loading state
  void _setLoading() {
    _setState(const AuthState.loading());
  }

  /// Set state and notify listeners
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}

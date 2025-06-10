import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/auth_user.dart';
import '../services/auth_service.dart';

/// Repository pattern for authentication operations
abstract class AuthRepository {
  /// Get current user
  AuthUser? get currentUser;

  /// Stream of authentication state changes
  Stream<AuthUser?> get authStateChanges;

  /// Sign in with email and password
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create user with email and password
  Future<AuthUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign in with Google (not supported)
  Future<AuthUser> signInWithGoogle();

  /// Send password reset email (redirects to TMDB)
  Future<void> sendPasswordResetEmail(String email);

  /// Send email verification (not applicable)
  Future<void> sendEmailVerification();

  /// Sign out
  Future<void> signOut();

  /// Delete user account (not supported via API)
  Future<void> deleteAccount();

  /// Update user profile (not supported via API)
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  });

  /// Create request token for TMDB authentication
  Future<String> createRequestToken();

  /// Create session from approved request token
  Future<AuthUser> createSessionFromToken(String requestToken);

  /// Create guest session
  Future<AuthUser> createGuestSession();

  /// Save user data locally
  Future<void> saveUserLocally(AuthUser user);

  /// Get user data from local storage
  Future<AuthUser?> getUserFromLocal();

  /// Clear local user data
  Future<void> clearLocalUserData();
}

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  static const String _userKey = 'auth_user';

  AuthRepositoryImpl(this._authService);

  @override
  AuthUser? get currentUser => _authService.currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => _authService.authStateChanges;

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await saveUserLocally(user);
    return user;
  }

  @override
  Future<AuthUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final user = await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    await saveUserLocally(user);
    return user;
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    await saveUserLocally(user);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  @override
  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
    await clearLocalUserData();
  }

  @override
  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    await clearLocalUserData();
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    await _authService.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );

    // Update local user data if available
    final updatedUser = _authService.currentUser;
    if (updatedUser != null) {
      await saveUserLocally(updatedUser);
    }
  }

  @override
  Future<String> createRequestToken() async {
    final token = await _authService.createRequestToken();
    return token.requestToken;
  }

  @override
  Future<AuthUser> createSessionFromToken(String requestToken) async {
    final user = await _authService.createSessionFromToken(requestToken);
    await saveUserLocally(user);
    return user;
  }

  @override
  Future<AuthUser> createGuestSession() async {
    final user = await _authService.createGuestSession();
    await saveUserLocally(user);
    return user;
  }

  @override
  Future<void> saveUserLocally(AuthUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      // Log error but don't throw - local storage is not critical
      // print('Failed to save user locally: $e');
      // TODO: Implement proper logging
    }
  }

  @override
  Future<AuthUser?> getUserFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return AuthUser.fromJson(userMap);
      }

      return null;
    } catch (e) {
      // Log error but don't throw - local storage is not critical
      // print('Failed to get user from local storage: $e');
      // TODO: Implement proper logging
      return null;
    }
  }

  @override
  Future<void> clearLocalUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      // Log error but don't throw - local storage is not critical
      // print('Failed to clear local user data: $e');
      // TODO: Implement proper logging
    }
  }
}

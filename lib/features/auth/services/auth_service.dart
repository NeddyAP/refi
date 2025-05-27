import '../models/auth_user.dart';
import '../models/tmdb_request_token.dart';
import 'tmdb_auth_service.dart';

/// Authentication service that handles TMDB Auth operations
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final TmdbAuthService _tmdbAuthService = TmdbAuthService();

  /// Initialize the service
  Future<void> initialize() async {
    await _tmdbAuthService.initialize();
  }

  /// Get current user
  AuthUser? get currentUser => _tmdbAuthService.currentUser;

  /// Stream of authentication state changes
  Stream<AuthUser?> get authStateChanges => _tmdbAuthService.authStateChanges;

  /// Sign in with TMDB username and password
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // For TMDB, email is actually username
      return await _tmdbAuthService.createSessionWithLogin(
        username: email.trim(),
        password: password,
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Create user with email and password (redirects to TMDB registration)
  Future<AuthUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // TMDB doesn't support direct registration via API
    // Users need to register on TMDB website
    throw Exception('Please register at https://www.themoviedb.org/signup and then sign in with your TMDB credentials.');
  }

  /// Sign in with Google (not supported by TMDB)
  Future<AuthUser> signInWithGoogle() async {
    throw Exception('Google Sign-In is not supported. Please use your TMDB username and password.');
  }

  /// Send password reset email (redirects to TMDB)
  Future<void> sendPasswordResetEmail(String email) async {
    throw Exception('Please reset your password at https://www.themoviedb.org/reset-password');
  }

  /// Send email verification (not applicable for TMDB)
  Future<void> sendEmailVerification() async {
    throw Exception('Email verification is not required for TMDB accounts.');
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _tmdbAuthService.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Delete user account (not supported via API)
  Future<void> deleteAccount() async {
    throw Exception('Account deletion must be done through TMDB website settings.');
  }

  /// Update user profile (not supported via API)
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    throw Exception('Profile updates must be done through TMDB website settings.');
  }

  /// Create request token for authentication
  Future<TmdbRequestToken> createRequestToken() async {
    try {
      return await _tmdbAuthService.createRequestToken();
    } catch (e) {
      throw Exception('Failed to create request token: $e');
    }
  }

  /// Create session from approved request token
  Future<AuthUser> createSessionFromToken(String requestToken) async {
    try {
      return await _tmdbAuthService.createSessionFromToken(requestToken);
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  /// Create guest session
  Future<AuthUser> createGuestSession() async {
    try {
      return await _tmdbAuthService.createGuestSession();
    } catch (e) {
      throw Exception('Failed to create guest session: $e');
    }
  }
}

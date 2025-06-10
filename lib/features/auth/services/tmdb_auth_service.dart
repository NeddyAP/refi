import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../models/auth_user.dart';
import '../models/tmdb_session.dart';
import '../models/tmdb_request_token.dart';
import '../models/tmdb_guest_session.dart';

/// TMDB Authentication service that handles TMDB API authentication operations
class TmdbAuthService {
  static final TmdbAuthService _instance = TmdbAuthService._internal();
  factory TmdbAuthService() => _instance;
  TmdbAuthService._internal();

  final ApiClient _apiClient = ApiClient();
  final StreamController<AuthUser?> _authStateController = StreamController<AuthUser?>.broadcast();

  AuthUser? _currentUser;
  static const String _userKey = 'tmdb_auth_user';
  static const String _guestSessionKey = 'tmdb_guest_session';

  /// Get current user
  AuthUser? get currentUser => _currentUser;

  /// Stream of authentication state changes
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  /// Initialize authentication service
  Future<void> initialize() async {
    await _loadStoredUser();

    // If no stored user, create a guest session
    if (_currentUser == null) {
      await _createGuestSession();
    }
  }

  /// Create a guest session for unauthenticated users
  Future<AuthUser> createGuestSession() async {
    try {
      final result = await _apiClient.get<TmdbGuestSession>(
        '/authentication/guest_session/new',
        fromJson: (json) => TmdbGuestSession.fromJson(json),
      );

      return result.when(
        success: (guestSession) async {
          final user = AuthUser.guest(guestSession);
          await _saveUser(user);
          await _saveGuestSession(guestSession);
          _setCurrentUser(user);
          return user;
        },
        error: (message, statusCode) => throw Exception('Failed to create guest session: $message'),
        loading: () => throw Exception('Unexpected loading state'),
      );
    } catch (e) {
      throw Exception('Failed to create guest session: $e');
    }
  }

  /// Create a request token for user authentication
  Future<TmdbRequestToken> createRequestToken() async {
    try {
      final result = await _apiClient.get<TmdbRequestToken>(
        '/authentication/token/new',
        fromJson: (json) => TmdbRequestToken.fromJson(json),
      );

      return result.when(
        success: (token) => token,
        error: (message, statusCode) => throw Exception('Failed to create request token: $message'),
        loading: () => throw Exception('Unexpected loading state'),
      );
    } catch (e) {
      throw Exception('Failed to create request token: $e');
    }
  }

  /// Create session with login credentials
  Future<AuthUser> createSessionWithLogin({
    required String username,
    required String password,
  }) async {
    try {
      // Step 1: Create request token
      final requestToken = await createRequestToken();

      // Step 2: Validate request token with login
      final validatedToken = await _validateTokenWithLogin(
        requestToken.requestToken,
        username,
        password,
      );

      // Step 3: Create session
      final session = await _createSession(validatedToken);

      // Step 4: Get account details
      final user = await _getAccountDetails(session);

      await _saveUser(user);
      _setCurrentUser(user);
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Create session from approved request token
  Future<AuthUser> createSessionFromToken(String requestToken) async {
    try {
      final session = await _createSession(requestToken);
      final user = await _getAccountDetails(session);

      await _saveUser(user);
      _setCurrentUser(user);
      return user;
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      if (_currentUser?.session != null) {
        // Delete session on TMDB
        await _deleteSession(_currentUser!.session!.sessionId);
      }
    } catch (e) {
      // Continue with local sign out even if server request fails
      // print('Failed to delete session on server: $e');
      // TODO: Implement proper logging
    }

    // Clear local data
    await _clearStoredUser();

    // Create new guest session
    await _createGuestSession();
  }

  /// Validate request token with login credentials
  Future<String> _validateTokenWithLogin(
    String requestToken,
    String username,
    String password,
  ) async {
    try {
      final result = await _apiClient.post<Map<String, dynamic>>(
        '/authentication/token/validate_with_login',
        data: {
          'username': username,
          'password': password,
          'request_token': requestToken,
        },
        fromJson: (json) => json,
      );

      return result.when(
        success: (response) {
          if (response['success'] == true) {
            return response['request_token'] as String;
          } else {
            throw Exception('Invalid credentials');
          }
        },
        error: (message, statusCode) => throw Exception('Authentication failed: $message'),
        loading: () => throw Exception('Unexpected loading state'),
      );
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  /// Create session from validated request token
  Future<TmdbSession> _createSession(String requestToken) async {
    try {
      final result = await _apiClient.post<TmdbSession>(
        '/authentication/session/new',
        data: {'request_token': requestToken},
        fromJson: (json) => TmdbSession.fromJson(json),
      );

      return result.when(
        success: (session) => session,
        error: (message, statusCode) => throw Exception('Failed to create session: $message'),
        loading: () => throw Exception('Unexpected loading state'),
      );
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  /// Get account details for authenticated user
  Future<AuthUser> _getAccountDetails(TmdbSession session) async {
    try {
      final result = await _apiClient.get<AuthUser>(
        '/account',
        queryParameters: {'session_id': session.sessionId},
        fromJson: (json) => AuthUser.fromTmdbAccount(json, session),
      );

      return result.when(
        success: (user) => user,
        error: (message, statusCode) => throw Exception('Failed to get account details: $message'),
        loading: () => throw Exception('Unexpected loading state'),
      );
    } catch (e) {
      throw Exception('Failed to get account details: $e');
    }
  }

  /// Delete session on TMDB
  Future<void> _deleteSession(String sessionId) async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/authentication/session',
        data: {'session_id': sessionId},
        fromJson: (json) => json,
      );
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  /// Create guest session internally
  Future<void> _createGuestSession() async {
    try {
      await createGuestSession();
    } catch (e) {
      // If guest session creation fails, create a minimal guest user
      final fallbackUser = AuthUser(
        id: 'guest_fallback',
        name: 'Guest User',
        isGuest: true,
        createdAt: DateTime.now(),
        lastSignInTime: DateTime.now(),
      );
      _setCurrentUser(fallbackUser);
    }
  }

  /// Set current user and notify listeners
  void _setCurrentUser(AuthUser? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  /// Load stored user from local storage
  Future<void> _loadStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        final user = AuthUser.fromJson(userData);

        // Check if session is still valid
        if (user.hasValidSession) {
          _setCurrentUser(user);
        } else {
          // Clear invalid session
          await _clearStoredUser();
        }
      }
    } catch (e) {
      // print('Failed to load stored user: $e');
      // TODO: Implement proper logging
      await _clearStoredUser();
    }
  }

  /// Save user to local storage
  Future<void> _saveUser(AuthUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      // print('Failed to save user: $e');
      // TODO: Implement proper logging
    }
  }

  /// Save guest session separately for easier access
  Future<void> _saveGuestSession(TmdbGuestSession guestSession) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = jsonEncode(guestSession.toJson());
      await prefs.setString(_guestSessionKey, sessionJson);
    } catch (e) {
      // print('Failed to save guest session: $e');
      // TODO: Implement proper logging
    }
  }

  /// Clear stored user data
  Future<void> _clearStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_guestSessionKey);
    } catch (e) {
      // print('Failed to clear stored user: $e');
      // TODO: Implement proper logging
    }
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}

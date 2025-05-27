import 'tmdb_session.dart';
import 'tmdb_guest_session.dart';

/// Authentication user model for TMDB users
class AuthUser {
  final String id;
  final String? username;
  final String? name;
  final String? email;
  final String? avatarPath;
  final bool includeAdult;
  final String iso639_1;
  final String iso3166_1;
  final DateTime? createdAt;
  final DateTime? lastSignInTime;
  final TmdbSession? session;
  final TmdbGuestSession? guestSession;
  final bool isGuest;

  const AuthUser({
    required this.id,
    this.username,
    this.name,
    this.email,
    this.avatarPath,
    this.includeAdult = false,
    this.iso639_1 = 'en',
    this.iso3166_1 = 'US',
    this.createdAt,
    this.lastSignInTime,
    this.session,
    this.guestSession,
    this.isGuest = false,
  });

  /// Create AuthUser from TMDB account details
  factory AuthUser.fromTmdbAccount(Map<String, dynamic> json, TmdbSession session) {
    return AuthUser(
      id: json['id'].toString(),
      username: json['username'] as String?,
      name: json['name'] as String?,
      email: null, // TMDB doesn't provide email in account details
      avatarPath: json['avatar']?['tmdb']?['avatar_path'] as String?,
      includeAdult: json['include_adult'] as bool? ?? false,
      iso639_1: json['iso_639_1'] as String? ?? 'en',
      iso3166_1: json['iso_3166_1'] as String? ?? 'US',
      createdAt: DateTime.now(),
      lastSignInTime: DateTime.now(),
      session: session,
      isGuest: false,
    );
  }

  /// Create AuthUser for guest session
  factory AuthUser.guest(TmdbGuestSession guestSession) {
    return AuthUser(
      id: 'guest_${guestSession.guestSessionId}',
      username: null,
      name: 'Guest User',
      email: null,
      avatarPath: null,
      createdAt: DateTime.now(),
      lastSignInTime: DateTime.now(),
      guestSession: guestSession,
      isGuest: true,
    );
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'avatarPath': avatarPath,
      'includeAdult': includeAdult,
      'iso639_1': iso639_1,
      'iso3166_1': iso3166_1,
      'createdAt': createdAt?.toIso8601String(),
      'lastSignInTime': lastSignInTime?.toIso8601String(),
      'session': session?.toJson(),
      'guestSession': guestSession?.toJson(),
      'isGuest': isGuest,
    };
  }

  /// Create from JSON
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      username: json['username'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatarPath: json['avatarPath'] as String?,
      includeAdult: json['includeAdult'] as bool? ?? false,
      iso639_1: json['iso639_1'] as String? ?? 'en',
      iso3166_1: json['iso3166_1'] as String? ?? 'US',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastSignInTime: json['lastSignInTime'] != null
          ? DateTime.parse(json['lastSignInTime'] as String)
          : null,
      session: json['session'] != null
          ? TmdbSession.fromStoredJson(json['session'] as Map<String, dynamic>)
          : null,
      guestSession: json['guestSession'] != null
          ? TmdbGuestSession.fromStoredJson(json['guestSession'] as Map<String, dynamic>)
          : null,
      isGuest: json['isGuest'] as bool? ?? false,
    );
  }

  /// Get display name
  String get displayName => name ?? username ?? 'User';

  /// Get initials for avatar
  String get initials {
    final displayName = this.displayName;
    if (displayName.isEmpty) return 'U';

    final words = displayName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return displayName[0].toUpperCase();
    }
  }

  /// Check if user has a profile photo
  bool get hasProfilePhoto => avatarPath != null && avatarPath!.isNotEmpty;

  /// Get full avatar URL
  String? get avatarUrl {
    if (avatarPath == null) return null;
    return 'https://image.tmdb.org/t/p/w200$avatarPath';
  }

  /// Get session ID for API requests
  String? get sessionId {
    if (isGuest) return guestSession?.guestSessionId;
    return session?.sessionId;
  }

  /// Check if session is valid
  bool get hasValidSession {
    if (isGuest) return guestSession?.isValid ?? false;
    return session?.isValid ?? false;
  }

  /// Copy with new values
  AuthUser copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    String? avatarPath,
    bool? includeAdult,
    String? iso639_1,
    String? iso3166_1,
    DateTime? createdAt,
    DateTime? lastSignInTime,
    TmdbSession? session,
    TmdbGuestSession? guestSession,
    bool? isGuest,
  }) {
    return AuthUser(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      includeAdult: includeAdult ?? this.includeAdult,
      iso639_1: iso639_1 ?? this.iso639_1,
      iso3166_1: iso3166_1 ?? this.iso3166_1,
      createdAt: createdAt ?? this.createdAt,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      session: session ?? this.session,
      guestSession: guestSession ?? this.guestSession,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AuthUser(id: $id, username: $username, name: $name, isGuest: $isGuest)';
}

/// TMDB Session model for authenticated users
class TmdbSession {
  final String sessionId;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const TmdbSession({
    required this.sessionId,
    required this.createdAt,
    this.expiresAt,
  });

  /// Create TmdbSession from API response
  factory TmdbSession.fromJson(Map<String, dynamic> json) {
    return TmdbSession(
      sessionId: json['session_id'] as String,
      createdAt: DateTime.now(),
      expiresAt: null, // TMDB sessions don't have explicit expiration
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// Create from stored JSON
  factory TmdbSession.fromStoredJson(Map<String, dynamic> json) {
    return TmdbSession(
      sessionId: json['session_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  /// Check if session is valid (not expired)
  bool get isValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  @override
  String toString() {
    return 'TmdbSession(sessionId: $sessionId, createdAt: $createdAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TmdbSession && other.sessionId == sessionId;
  }

  @override
  int get hashCode => sessionId.hashCode;
}

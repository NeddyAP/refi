/// TMDB Guest Session model for unauthenticated users
class TmdbGuestSession {
  final String guestSessionId;
  final DateTime expiresAt;
  final bool success;

  const TmdbGuestSession({
    required this.guestSessionId,
    required this.expiresAt,
    required this.success,
  });

  /// Create TmdbGuestSession from API response
  factory TmdbGuestSession.fromJson(Map<String, dynamic> json) {
    return TmdbGuestSession(
      guestSessionId: json['guest_session_id'] as String,
      expiresAt: _parseDateTime(json['expires_at'] as String),
      success: json['success'] as bool,
    );
  }

  /// Parse TMDB date format "YYYY-MM-DD HH:mm:ss UTC"
  static DateTime _parseDateTime(String dateString) {
    try {
      // Remove " UTC" suffix if present and parse as UTC
      final cleanDateString = dateString.replaceAll(' UTC', '');
      return DateTime.parse('${cleanDateString}Z'); // Add Z to indicate UTC
    } catch (e) {
      // Fallback to original parsing if custom parsing fails
      return DateTime.parse(dateString);
    }
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'guest_session_id': guestSessionId,
      'expires_at': expiresAt.toIso8601String(),
      'success': success,
    };
  }

  /// Create from stored JSON
  factory TmdbGuestSession.fromStoredJson(Map<String, dynamic> json) {
    return TmdbGuestSession(
      guestSessionId: json['guest_session_id'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      success: json['success'] as bool,
    );
  }

  /// Check if guest session is still valid (not expired)
  bool get isValid {
    return DateTime.now().isBefore(expiresAt) && success;
  }

  @override
  String toString() {
    return 'TmdbGuestSession(guestSessionId: $guestSessionId, expiresAt: $expiresAt, success: $success)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TmdbGuestSession && other.guestSessionId == guestSessionId;
  }

  @override
  int get hashCode => guestSessionId.hashCode;
}

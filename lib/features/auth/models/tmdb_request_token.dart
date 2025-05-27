/// TMDB Request Token model for authentication flow
class TmdbRequestToken {
  final String requestToken;
  final DateTime expiresAt;
  final bool success;

  const TmdbRequestToken({
    required this.requestToken,
    required this.expiresAt,
    required this.success,
  });

  /// Create TmdbRequestToken from API response
  factory TmdbRequestToken.fromJson(Map<String, dynamic> json) {
    return TmdbRequestToken(
      requestToken: json['request_token'] as String,
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

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'request_token': requestToken,
      'expires_at': expiresAt.toIso8601String(),
      'success': success,
    };
  }

  /// Check if token is still valid (not expired)
  bool get isValid {
    return DateTime.now().isBefore(expiresAt) && success;
  }

  /// Get TMDB authentication URL
  String getAuthenticationUrl({String? redirectTo}) {
    final baseUrl = 'https://www.themoviedb.org/authenticate/$requestToken';
    if (redirectTo != null) {
      return '$baseUrl?redirect_to=${Uri.encodeComponent(redirectTo)}';
    }
    return baseUrl;
  }

  @override
  String toString() {
    return 'TmdbRequestToken(requestToken: $requestToken, expiresAt: $expiresAt, success: $success)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TmdbRequestToken && other.requestToken == requestToken;
  }

  @override
  int get hashCode => requestToken.hashCode;
}

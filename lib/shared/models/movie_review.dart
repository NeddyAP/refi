class ReviewAuthor {
  final String name;
  final String username;
  final String? avatarPath;
  final double? rating;

  const ReviewAuthor({
    required this.name,
    required this.username,
    this.avatarPath,
    this.rating,
  });

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) {
    return ReviewAuthor(
      name: json['name'] as String? ?? '',
      username: json['username'] as String,
      avatarPath: json['avatar_path'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'avatar_path': avatarPath,
      'rating': rating,
    };
  }

  /// Get full avatar URL
  String? get fullAvatarUrl {
    if (avatarPath == null) return null;
    // Handle both TMDB and Gravatar URLs
    if (avatarPath!.startsWith('/https://')) {
      return avatarPath!.substring(1); // Remove leading slash
    }
    return 'https://image.tmdb.org/t/p/w185$avatarPath';
  }

  /// Get display name (prefer name over username)
  String get displayName => name.isNotEmpty ? name : username;
}

class MovieReview {
  final String id;
  final String author;
  final ReviewAuthor authorDetails;
  final String content;
  final String createdAt;
  final String updatedAt;
  final String url;

  const MovieReview({
    required this.id,
    required this.author,
    required this.authorDetails,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.url,
  });

  factory MovieReview.fromJson(Map<String, dynamic> json) {
    return MovieReview(
      id: json['id'] as String,
      author: json['author'] as String,
      authorDetails: ReviewAuthor.fromJson(json['author_details'] as Map<String, dynamic>),
      content: json['content'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'author_details': authorDetails.toJson(),
      'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'url': url,
    };
  }

  /// Get formatted creation date
  String get formattedCreatedAt {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdAt;
    }
  }

  /// Get truncated content for preview
  String getTruncatedContent([int maxLength = 200]) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  /// Get rating stars count (0-5)
  int get ratingStars {
    if (authorDetails.rating == null) return 0;
    return (authorDetails.rating! / 2).round().clamp(0, 5);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovieReview && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MovieReview(id: $id, author: $author)';
}

class MovieReviewsResponse {
  final int id;
  final int page;
  final List<MovieReview> results;
  final int totalPages;
  final int totalResults;

  const MovieReviewsResponse({
    required this.id,
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieReviewsResponse.fromJson(Map<String, dynamic> json) {
    return MovieReviewsResponse(
      id: json['id'] as int,
      page: json['page'] as int,
      results: (json['results'] as List<dynamic>)
          .map((review) => MovieReview.fromJson(review as Map<String, dynamic>))
          .toList(),
      totalPages: json['total_pages'] as int,
      totalResults: json['total_results'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page': page,
      'results': results.map((review) => review.toJson()).toList(),
      'total_pages': totalPages,
      'total_results': totalResults,
    };
  }

  /// Check if there are more pages
  bool get hasNextPage => page < totalPages;

  /// Get reviews with ratings only
  List<MovieReview> get ratedReviews => results.where(
        (review) => review.authorDetails.rating != null,
      ).toList();
}
class MovieImage {
  final double aspectRatio;
  final int height;
  final String? iso6391;
  final String filePath;
  final double voteAverage;
  final int voteCount;
  final int width;

  const MovieImage({
    required this.aspectRatio,
    required this.height,
    this.iso6391,
    required this.filePath,
    required this.voteAverage,
    required this.voteCount,
    required this.width,
  });

  factory MovieImage.fromJson(Map<String, dynamic> json) {
    return MovieImage(
      aspectRatio: (json['aspect_ratio'] as num).toDouble(),
      height: json['height'] as int,
      iso6391: json['iso_639_1'] as String?,
      filePath: json['file_path'] as String,
      voteAverage: (json['vote_average'] as num).toDouble(),
      voteCount: json['vote_count'] as int,
      width: json['width'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aspect_ratio': aspectRatio,
      'height': height,
      'iso_639_1': iso6391,
      'file_path': filePath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'width': width,
    };
  }

  /// Get full image URL with specified size
  String getFullImageUrl([String size = 'w500']) {
    return 'https://image.tmdb.org/t/p/$size$filePath';
  }

  /// Get thumbnail URL
  String get thumbnailUrl => getFullImageUrl('w300');

  /// Get medium size URL
  String get mediumUrl => getFullImageUrl('w500');

  /// Get large size URL
  String get largeUrl => getFullImageUrl('w780');

  /// Get original size URL
  String get originalUrl => getFullImageUrl('original');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovieImage && other.filePath == filePath;
  }

  @override
  int get hashCode => filePath.hashCode;

  @override
  String toString() => 'MovieImage(filePath: $filePath, width: $width, height: $height)';
}

class MovieImagesResponse {
  final int id;
  final List<MovieImage> backdrops;
  final List<MovieImage> logos;
  final List<MovieImage> posters;

  const MovieImagesResponse({
    required this.id,
    required this.backdrops,
    required this.logos,
    required this.posters,
  });

  factory MovieImagesResponse.fromJson(Map<String, dynamic> json) {
    return MovieImagesResponse(
      id: json['id'] as int,
      backdrops: (json['backdrops'] as List<dynamic>)
          .map((image) => MovieImage.fromJson(image as Map<String, dynamic>))
          .toList(),
      logos: (json['logos'] as List<dynamic>)
          .map((image) => MovieImage.fromJson(image as Map<String, dynamic>))
          .toList(),
      posters: (json['posters'] as List<dynamic>)
          .map((image) => MovieImage.fromJson(image as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'backdrops': backdrops.map((image) => image.toJson()).toList(),
      'logos': logos.map((image) => image.toJson()).toList(),
      'posters': posters.map((image) => image.toJson()).toList(),
    };
  }

  /// Get all images combined
  List<MovieImage> get allImages => [...backdrops, ...logos, ...posters];

  /// Get highly rated backdrops (vote_average >= 7.0)
  List<MovieImage> get topBackdrops => backdrops
      .where((image) => image.voteAverage >= 7.0)
      .toList()
    ..sort((a, b) => b.voteAverage.compareTo(a.voteAverage));

  /// Get highly rated posters (vote_average >= 7.0)
  List<MovieImage> get topPosters => posters
      .where((image) => image.voteAverage >= 7.0)
      .toList()
    ..sort((a, b) => b.voteAverage.compareTo(a.voteAverage));

  /// Get English language images only
  List<MovieImage> get englishBackdrops => backdrops
      .where((image) => image.iso6391 == 'en' || image.iso6391 == null)
      .toList();

  /// Get English language posters only
  List<MovieImage> get englishPosters => posters
      .where((image) => image.iso6391 == 'en' || image.iso6391 == null)
      .toList();

  /// Check if there are any images
  bool get hasImages => backdrops.isNotEmpty || logos.isNotEmpty || posters.isNotEmpty;

  /// Get total image count
  int get totalImageCount => backdrops.length + logos.length + posters.length;
}
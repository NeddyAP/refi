class MovieVideo {
  final String id;
  final String key;
  final String name;
  final String site;
  final int size;
  final String type;
  final bool official;
  final String? publishedAt;

  const MovieVideo({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.size,
    required this.type,
    required this.official,
    this.publishedAt,
  });

  factory MovieVideo.fromJson(Map<String, dynamic> json) {
    return MovieVideo(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      site: json['site'] as String,
      size: json['size'] as int,
      type: json['type'] as String,
      official: json['official'] as bool,
      publishedAt: json['published_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'site': site,
      'size': size,
      'type': type,
      'official': official,
      'published_at': publishedAt,
    };
  }

  /// Get YouTube thumbnail URL
  String? get youtubeThumbnailUrl {
    if (site.toLowerCase() == 'youtube') {
      return 'https://img.youtube.com/vi/$key/hqdefault.jpg';
    }
    return null;
  }

  /// Get YouTube video URL
  String? get youtubeUrl {
    if (site.toLowerCase() == 'youtube') {
      return 'https://www.youtube.com/watch?v=$key';
    }
    return null;
  }

  /// Check if this is a trailer
  bool get isTrailer => type.toLowerCase() == 'trailer';

  /// Check if this is a teaser
  bool get isTeaser => type.toLowerCase() == 'teaser';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovieVideo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MovieVideo(id: $id, name: $name, type: $type)';
}

class MovieVideosResponse {
  final int id;
  final List<MovieVideo> results;

  const MovieVideosResponse({
    required this.id,
    required this.results,
  });

  factory MovieVideosResponse.fromJson(Map<String, dynamic> json) {
    return MovieVideosResponse(
      id: json['id'] as int,
      results: (json['results'] as List<dynamic>)
          .map((video) => MovieVideo.fromJson(video as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'results': results.map((video) => video.toJson()).toList(),
    };
  }

  /// Get only trailers
  List<MovieVideo> get trailers => results.where((video) => video.isTrailer).toList();

  /// Get only teasers
  List<MovieVideo> get teasers => results.where((video) => video.isTeaser).toList();

  /// Get YouTube videos only
  List<MovieVideo> get youtubeVideos => results.where((video) => video.site.toLowerCase() == 'youtube').toList();
}
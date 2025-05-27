import 'movie.dart';
import 'tv_show.dart';

enum MediaType { movie, tv }

class MixedContentItem {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final String originalLanguage;
  final String originalTitle;
  final double popularity;
  final MediaType mediaType;

  const MixedContentItem({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    required this.originalLanguage,
    required this.originalTitle,
    required this.popularity,
    required this.mediaType,
  });

  factory MixedContentItem.fromJson(Map<String, dynamic> json) {
    final mediaType = json['media_type'] as String?;
    final isMovie = mediaType == 'movie';
    
    return MixedContentItem(
      id: json['id'] as int,
      title: isMovie 
          ? json['title'] as String 
          : json['name'] as String,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: isMovie 
          ? json['release_date'] as String?
          : json['first_air_date'] as String?,
      voteAverage: (json['vote_average'] as num).toDouble(),
      voteCount: json['vote_count'] as int,
      genreIds: (json['genre_ids'] as List<dynamic>).cast<int>(),
      originalLanguage: json['original_language'] as String,
      originalTitle: isMovie 
          ? json['original_title'] as String
          : json['original_name'] as String,
      popularity: (json['popularity'] as num).toDouble(),
      mediaType: isMovie ? MediaType.movie : MediaType.tv,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'genre_ids': genreIds,
      'original_language': originalLanguage,
      'original_title': originalTitle,
      'popularity': popularity,
      'media_type': mediaType == MediaType.movie ? 'movie' : 'tv',
    };
  }

  /// Convert to Movie object (if it's a movie)
  Movie? toMovie() {
    if (mediaType != MediaType.movie) return null;
    
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
      voteCount: voteCount,
      genreIds: genreIds,
      adult: false, // Default value since trending doesn't include adult flag
      originalLanguage: originalLanguage,
      originalTitle: originalTitle,
      popularity: popularity,
      video: false, // Default value
    );
  }

  /// Convert to TvShow object (if it's a TV show)
  TvShow? toTvShow() {
    if (mediaType != MediaType.tv) return null;
    
    return TvShow(
      id: id,
      name: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      firstAirDate: releaseDate,
      voteAverage: voteAverage,
      voteCount: voteCount,
      genreIds: genreIds,
      originalLanguage: originalLanguage,
      originalName: originalTitle,
      popularity: popularity,
      originCountry: [], // Default empty list since trending doesn't include this
    );
  }

  /// Get full poster URL
  String? get fullPosterUrl {
    if (posterPath == null) return null;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  /// Get full backdrop URL
  String? get fullBackdropUrl {
    if (backdropPath == null) return null;
    return 'https://image.tmdb.org/t/p/w1280$backdropPath';
  }

  /// Get release/air year
  String? get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return null;
    return releaseDate!.split('-').first;
  }

  /// Get formatted rating
  String get formattedRating => voteAverage.toStringAsFixed(1);

  /// Get media type display string
  String get mediaTypeString => mediaType == MediaType.movie ? 'Movie' : 'TV Show';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MixedContentItem && other.id == id && other.mediaType == mediaType;
  }

  @override
  int get hashCode => Object.hash(id, mediaType);

  @override
  String toString() => 'MixedContentItem(id: $id, title: $title, type: $mediaTypeString)';
}

class MixedContentResponse {
  final int page;
  final List<MixedContentItem> results;
  final int totalPages;
  final int totalResults;

  const MixedContentResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory MixedContentResponse.fromJson(Map<String, dynamic> json) {
    return MixedContentResponse(
      page: json['page'] as int,
      results: (json['results'] as List<dynamic>)
          .map((item) => MixedContentItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPages: json['total_pages'] as int,
      totalResults: json['total_results'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'results': results.map((item) => item.toJson()).toList(),
      'total_pages': totalPages,
      'total_results': totalResults,
    };
  }
}
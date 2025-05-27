import 'genre.dart';

class MovieDetails {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<Genre> genres;
  final bool adult;
  final String originalLanguage;
  final String originalTitle;
  final double popularity;
  final bool video;
  final int? runtime;
  final String? status;
  final String? tagline;
  final int? budget;
  final int? revenue;
  final String? homepage;
  final String? imdbId;

  const MovieDetails({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genres,
    required this.adult,
    required this.originalLanguage,
    required this.originalTitle,
    required this.popularity,
    required this.video,
    this.runtime,
    this.status,
    this.tagline,
    this.budget,
    this.revenue,
    this.homepage,
    this.imdbId,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num).toDouble(),
      voteCount: json['vote_count'] as int,
      genres: (json['genres'] as List<dynamic>)
          .map((genre) => Genre.fromJson(genre as Map<String, dynamic>))
          .toList(),
      adult: json['adult'] as bool,
      originalLanguage: json['original_language'] as String,
      originalTitle: json['original_title'] as String,
      popularity: (json['popularity'] as num).toDouble(),
      video: json['video'] as bool,
      runtime: json['runtime'] as int?,
      status: json['status'] as String?,
      tagline: json['tagline'] as String?,
      budget: json['budget'] as int?,
      revenue: json['revenue'] as int?,
      homepage: json['homepage'] as String?,
      imdbId: json['imdb_id'] as String?,
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
      'genres': genres.map((genre) => genre.toJson()).toList(),
      'adult': adult,
      'original_language': originalLanguage,
      'original_title': originalTitle,
      'popularity': popularity,
      'video': video,
      'runtime': runtime,
      'status': status,
      'tagline': tagline,
      'budget': budget,
      'revenue': revenue,
      'homepage': homepage,
      'imdb_id': imdbId,
    };
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

  /// Get release year
  String? get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return null;
    return releaseDate!.split('-').first;
  }

  /// Get formatted rating
  String get formattedRating => voteAverage.toStringAsFixed(1);

  /// Get formatted runtime
  String? get formattedRuntime {
    if (runtime == null) return null;
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get genre names as comma-separated string
  String get genreNames {
    return genres.map((genre) => genre.name).join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovieDetails && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MovieDetails(id: $id, title: $title)';
}

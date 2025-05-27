class TvShow {
  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? firstAirDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final String originalLanguage;
  final String originalName;
  final double popularity;
  final List<String> originCountry;

  const TvShow({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.firstAirDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    required this.originalLanguage,
    required this.originalName,
    required this.popularity,
    required this.originCountry,
  });

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'] as int,
      name: json['name'] as String,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      firstAirDate: json['first_air_date'] as String?,
      voteAverage: (json['vote_average'] as num).toDouble(),
      voteCount: json['vote_count'] as int,
      genreIds: (json['genre_ids'] as List<dynamic>).cast<int>(),
      originalLanguage: json['original_language'] as String,
      originalName: json['original_name'] as String,
      popularity: (json['popularity'] as num).toDouble(),
      originCountry: (json['origin_country'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'first_air_date': firstAirDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'genre_ids': genreIds,
      'original_language': originalLanguage,
      'original_name': originalName,
      'popularity': popularity,
      'origin_country': originCountry,
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

  /// Get first air year
  String? get firstAirYear {
    if (firstAirDate == null || firstAirDate!.isEmpty) return null;
    return firstAirDate!.split('-').first;
  }

  /// Get formatted rating
  String get formattedRating => voteAverage.toStringAsFixed(1);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TvShow && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TvShow(id: $id, name: $name)';
}

class TvShowResponse {
  final int page;
  final List<TvShow> results;
  final int totalPages;
  final int totalResults;

  const TvShowResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory TvShowResponse.fromJson(Map<String, dynamic> json) {
    return TvShowResponse(
      page: json['page'] as int,
      results: (json['results'] as List<dynamic>)
          .map((tv) => TvShow.fromJson(tv as Map<String, dynamic>))
          .toList(),
      totalPages: json['total_pages'] as int,
      totalResults: json['total_results'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'results': results.map((tv) => tv.toJson()).toList(),
      'total_pages': totalPages,
      'total_results': totalResults,
    };
  }
}
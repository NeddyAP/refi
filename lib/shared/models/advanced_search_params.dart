class AdvancedSearchParams {
  final List<int>? genreIds;
  final int? releaseYear;
  final int? releaseYearStart;
  final int? releaseYearEnd;
  final double? ratingMin;
  final double? ratingMax;
  final int? minVoteCount;
  final String? originalLanguage;
  final List<int>? excludeGenreIds;
  final int? runtimeMin;
  final int? runtimeMax;
  final String? sortBy;
  final bool? includeAdult;
  final bool? includeVideo;
  final String? certification;
  final String? certificationCountry;
  final int page;

  const AdvancedSearchParams({
    this.genreIds,
    this.releaseYear,
    this.releaseYearStart,
    this.releaseYearEnd,
    this.ratingMin,
    this.ratingMax,
    this.minVoteCount,
    this.originalLanguage,
    this.excludeGenreIds,
    this.runtimeMin,
    this.runtimeMax,
    this.sortBy = 'popularity.desc',
    this.includeAdult = false,
    this.includeVideo = false,
    this.certification,
    this.certificationCountry,
    this.page = 1,
  });

  AdvancedSearchParams copyWith({
    List<int>? genreIds,
    int? releaseYear,
    int? releaseYearStart,
    int? releaseYearEnd,
    double? ratingMin,
    double? ratingMax,
    int? minVoteCount,
    String? originalLanguage,
    List<int>? excludeGenreIds,
    int? runtimeMin,
    int? runtimeMax,
    String? sortBy,
    bool? includeAdult,
    bool? includeVideo,
    String? certification,
    String? certificationCountry,
    int? page,
  }) {
    return AdvancedSearchParams(
      genreIds: genreIds ?? this.genreIds,
      releaseYear: releaseYear ?? this.releaseYear,
      releaseYearStart: releaseYearStart ?? this.releaseYearStart,
      releaseYearEnd: releaseYearEnd ?? this.releaseYearEnd,
      ratingMin: ratingMin ?? this.ratingMin,
      ratingMax: ratingMax ?? this.ratingMax,
      minVoteCount: minVoteCount ?? this.minVoteCount,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      excludeGenreIds: excludeGenreIds ?? this.excludeGenreIds,
      runtimeMin: runtimeMin ?? this.runtimeMin,
      runtimeMax: runtimeMax ?? this.runtimeMax,
      sortBy: sortBy ?? this.sortBy,
      includeAdult: includeAdult ?? this.includeAdult,
      includeVideo: includeVideo ?? this.includeVideo,
      certification: certification ?? this.certification,
      certificationCountry: certificationCountry ?? this.certificationCountry,
      page: page ?? this.page,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {
      'page': page,
      'sort_by': sortBy,
      'include_adult': includeAdult.toString(),
      'include_video': includeVideo.toString(),
    };

    if (genreIds != null && genreIds!.isNotEmpty) {
      params['with_genres'] = genreIds!.join(',');
    }

    if (releaseYear != null) {
      params['primary_release_year'] = releaseYear;
    }

    if (releaseYearStart != null) {
      params['primary_release_date.gte'] = '$releaseYearStart-01-01';
    }

    if (releaseYearEnd != null) {
      params['primary_release_date.lte'] = '$releaseYearEnd-12-31';
    }

    if (ratingMin != null) {
      params['vote_average.gte'] = ratingMin;
    }

    if (ratingMax != null) {
      params['vote_average.lte'] = ratingMax;
    }

    if (minVoteCount != null) {
      params['vote_count.gte'] = minVoteCount;
    }

    if (originalLanguage != null && originalLanguage!.isNotEmpty) {
      params['with_original_language'] = originalLanguage;
    }

    if (excludeGenreIds != null && excludeGenreIds!.isNotEmpty) {
      params['without_genres'] = excludeGenreIds!.join(',');
    }

    if (runtimeMin != null) {
      params['with_runtime.gte'] = runtimeMin;
    }

    if (runtimeMax != null) {
      params['with_runtime.lte'] = runtimeMax;
    }

    if (certification != null && certification!.isNotEmpty) {
      params['certification'] = certification;
    }

    if (certificationCountry != null && certificationCountry!.isNotEmpty) {
      params['certification_country'] = certificationCountry;
    }

    return params;
  }

  bool get isEmpty {
    return genreIds == null &&
        releaseYear == null &&
        releaseYearStart == null &&
        releaseYearEnd == null &&
        ratingMin == null &&
        ratingMax == null &&
        minVoteCount == null &&
        (originalLanguage == null || originalLanguage!.isEmpty) &&
        excludeGenreIds == null &&
        runtimeMin == null &&
        runtimeMax == null &&
        (certification == null || certification!.isEmpty);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AdvancedSearchParams &&
        _listEquals(other.genreIds, genreIds) &&
        other.releaseYear == releaseYear &&
        other.releaseYearStart == releaseYearStart &&
        other.releaseYearEnd == releaseYearEnd &&
        other.ratingMin == ratingMin &&
        other.ratingMax == ratingMax &&
        other.minVoteCount == minVoteCount &&
        other.originalLanguage == originalLanguage &&
        _listEquals(other.excludeGenreIds, excludeGenreIds) &&
        other.runtimeMin == runtimeMin &&
        other.runtimeMax == runtimeMax &&
        other.sortBy == sortBy &&
        other.includeAdult == includeAdult &&
        other.includeVideo == includeVideo &&
        other.certification == certification &&
        other.certificationCountry == certificationCountry &&
        other.page == page;
  }

  @override
  int get hashCode {
    return Object.hash(
      genreIds,
      releaseYear,
      releaseYearStart,
      releaseYearEnd,
      ratingMin,
      ratingMax,
      minVoteCount,
      originalLanguage,
      excludeGenreIds,
      runtimeMin,
      runtimeMax,
      sortBy,
      includeAdult,
      includeVideo,
      certification,
      certificationCountry,
      page,
    );
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
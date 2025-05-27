import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/constants/api_constants.dart';
import '../models/movie.dart';
import '../models/movie_details.dart';
import '../models/genre.dart';
import '../models/tv_show.dart';
import '../models/mixed_content.dart';
import '../models/movie_video.dart';
import '../models/movie_cast.dart';
import '../models/movie_review.dart';
import '../models/movie_images.dart';
import '../models/advanced_search_params.dart';

abstract class MovieRepository {
  Future<ApiResult<MovieResponse>> getPopularMovies({int page = 1});
  Future<ApiResult<MovieResponse>> getTopRatedMovies({int page = 1});
  Future<ApiResult<MovieResponse>> getUpcomingMovies({int page = 1});
  Future<ApiResult<MovieResponse>> getNowPlayingMovies({int page = 1});
  Future<ApiResult<MovieResponse>> searchMovies(String query, {int page = 1});
  Future<ApiResult<MovieDetails>> getMovieDetails(int movieId);
  Future<ApiResult<MovieVideosResponse>> getMovieVideos(int movieId);
  Future<ApiResult<MovieCreditsResponse>> getMovieCredits(int movieId);
  Future<ApiResult<MovieReviewsResponse>> getMovieReviews(int movieId, {int page = 1});
  Future<ApiResult<MovieImagesResponse>> getMovieImages(int movieId);
  Future<ApiResult<GenreResponse>> getGenres();
  Future<ApiResult<MovieResponse>> getMoviesByGenre(int genreId, {int page = 1});
  Future<ApiResult<MovieResponse>> discoverMovies(AdvancedSearchParams params);
  
  // New methods for enhanced home screen content
  Future<ApiResult<MixedContentResponse>> getTrendingToday({int page = 1});
  Future<ApiResult<MixedContentResponse>> getTrendingThisWeek({int page = 1});
  Future<ApiResult<MovieResponse>> getLatestTrailers({int page = 1});
  Future<ApiResult<MovieResponse>> getPopularOnStreaming({int page = 1});
  Future<ApiResult<TvShowResponse>> getPopularOnTv({int page = 1});
  Future<ApiResult<MovieResponse>> getAvailableForRent({int page = 1});
  Future<ApiResult<MovieResponse>> getCurrentlyInTheaters({int page = 1});
}

class MovieRepositoryImpl implements MovieRepository {
  final ApiClient _apiClient;

  MovieRepositoryImpl(this._apiClient);

  @override
  Future<ApiResult<MovieResponse>> getPopularMovies({int page = 1}) async {
    return await _apiClient.get(
      ApiConstants.popularMovies,
      queryParameters: {
        ApiConstants.pageParam: page,
      },
      fromJson: (json) => MovieResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieResponse>> getTopRatedMovies({int page = 1}) async {
    return await _apiClient.get(
      ApiConstants.topRatedMovies,
      queryParameters: {
        ApiConstants.pageParam: page,
      },
      fromJson: (json) => MovieResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieResponse>> getUpcomingMovies({int page = 1}) async {
    return await _apiClient.get(
      ApiConstants.upcomingMovies,
      queryParameters: {
        ApiConstants.pageParam: page,
      },
      fromJson: (json) => MovieResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieResponse>> getNowPlayingMovies({int page = 1}) async {
    return await _apiClient.get(
      ApiConstants.nowPlayingMovies,
      queryParameters: {
        ApiConstants.pageParam: page,
      },
      fromJson: (json) => MovieResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieResponse>> searchMovies(String query, {int page = 1}) async {
    return await _apiClient.get(
      ApiConstants.searchMovies,
      queryParameters: {
        ApiConstants.queryParam: query,
        ApiConstants.pageParam: page,
      },
      fromJson: (json) => MovieResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieDetails>> getMovieDetails(int movieId) async {
    return await _apiClient.get(
      '${ApiConstants.movieDetails}/$movieId',
      fromJson: (json) => MovieDetails.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieVideosResponse>> getMovieVideos(int movieId) async {
    return await _apiClient.get(
      '${ApiConstants.movieDetails}/$movieId${ApiConstants.movieVideos}',
      fromJson: (json) => MovieVideosResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieCreditsResponse>> getMovieCredits(int movieId) async {
    return await _apiClient.get(
      '${ApiConstants.movieDetails}/$movieId${ApiConstants.movieCredits}',
      fromJson: (json) => MovieCreditsResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieReviewsResponse>> getMovieReviews(int movieId, {int page = 1}) async {
    return await _apiClient.get(
      '${ApiConstants.movieDetails}/$movieId${ApiConstants.movieReviews}',
      queryParameters: {
        ApiConstants.pageParam: page,
      },
      fromJson: (json) => MovieReviewsResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieImagesResponse>> getMovieImages(int movieId) async {
    return await _apiClient.get(
      '${ApiConstants.movieDetails}/$movieId${ApiConstants.movieImages}',
      fromJson: (json) => MovieImagesResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<GenreResponse>> getGenres() async {
    return await _apiClient.get(
      ApiConstants.genres,
      fromJson: (json) => GenreResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieResponse>> getMoviesByGenre(int genreId, {int page = 1}) async {
    return await _apiClient.get(
      '/discover/movie',
      queryParameters: {
        ApiConstants.genreParam: genreId.toString(),
        ApiConstants.pageParam: page,
        ApiConstants.sortByParam: 'popularity.desc',
      },
      fromJson: (json) => MovieResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieResponse>> discoverMovies(AdvancedSearchParams params) async {
    return await _apiClient.get(
      ApiConstants.discoverMovie,
      queryParameters: params.toQueryParameters(),
      fromJson: (json) => MovieResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MixedContentResponse>> getTrendingToday({int page = 1}) async {
    return await _apiClient.get(
      '${ApiConstants.trendingAll}/day',
      queryParameters: {
        ApiConstants.pageParam: page,
      },
      fromJson: (json) => MixedContentResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MixedContentResponse>> getTrendingThisWeek({int page = 1}) async {
    return await _apiClient.get(
      '${ApiConstants.trendingAll}/week',
      queryParameters: {
        ApiConstants.pageParam: page,
      },
      fromJson: (json) => MixedContentResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieResponse>> getLatestTrailers({int page = 1}) async {
    // Get upcoming movies with videos, sorted by release date
    return await _apiClient.get(
      ApiConstants.discoverMovie,
      queryParameters: {
        ApiConstants.pageParam: page,
        ApiConstants.sortByParam: 'release_date.desc',
        'include_video': 'true',
        'with_release_type': '2|3', // Theatrical releases
        ApiConstants.releaseDateGteParam: DateTime.now().toIso8601String().split('T')[0],
      },
      fromJson: (json) => MovieResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieResponse>> getPopularOnStreaming({int page = 1}) async {
    // Get popular movies filtered by streaming providers
    return await _apiClient.get(
      ApiConstants.discoverMovie,
      queryParameters: {
        ApiConstants.pageParam: page,
        ApiConstants.sortByParam: 'popularity.desc',
        ApiConstants.withWatchMonetizationTypesParam: 'flatrate',
        ApiConstants.watchRegionParam: 'US',
      },
      fromJson: (json) => MovieResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<TvShowResponse>> getPopularOnTv({int page = 1}) async {
    return await _apiClient.get(
      ApiConstants.popularTv,
      queryParameters: {
        ApiConstants.pageParam: page,
      },
      fromJson: (json) => TvShowResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieResponse>> getAvailableForRent({int page = 1}) async {
    // Get movies available for rent
    return await _apiClient.get(
      ApiConstants.discoverMovie,
      queryParameters: {
        ApiConstants.pageParam: page,
        ApiConstants.sortByParam: 'popularity.desc',
        ApiConstants.withWatchMonetizationTypesParam: 'rent',
        ApiConstants.watchRegionParam: 'US',
      },
      fromJson: (json) => MovieResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<MovieResponse>> getCurrentlyInTheaters({int page = 1}) async {
    // Use now playing endpoint for movies currently in theaters
    return await getNowPlayingMovies(page: page);
  }
}

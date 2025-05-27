import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/constants/api_constants.dart';
import '../models/movie.dart';
import '../models/movie_details.dart';
import '../models/genre.dart';

abstract class MovieRepository {
  Future<ApiResult<MovieResponse>> getPopularMovies({int page = 1});
  Future<ApiResult<MovieResponse>> getTopRatedMovies({int page = 1});
  Future<ApiResult<MovieResponse>> getUpcomingMovies({int page = 1});
  Future<ApiResult<MovieResponse>> getNowPlayingMovies({int page = 1});
  Future<ApiResult<MovieResponse>> searchMovies(String query, {int page = 1});
  Future<ApiResult<MovieDetails>> getMovieDetails(int movieId);
  Future<ApiResult<GenreResponse>> getGenres();
  Future<ApiResult<MovieResponse>> getMoviesByGenre(int genreId, {int page = 1});
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
}

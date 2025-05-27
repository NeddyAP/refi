import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/constants/api_constants.dart';
import '../../features/auth/models/auth_user.dart';
import '../models/movie.dart';

class TmdbAccountRepository {
  final ApiClient _apiClient;
  final AuthUser Function() _getCurrentUser;

  TmdbAccountRepository(this._apiClient, this._getCurrentUser);

  /// Fetch favorite movies from TMDB
  Future<ApiResult<List<Movie>>> getFavoriteMovies({int page = 1}) async {
    final user = _getCurrentUser();
    if (user.isGuest) {
      return const ApiSuccess([]);
    }
    final endpoint = ApiConstants.favoriteMovies.replaceFirst(
      '{account_id}',
      user.id,
    );
    final result = await _apiClient.get(
      endpoint,
      queryParameters: {'session_id': user.sessionId, 'page': page},
      fromJson: (json) => (json['results'] as List<dynamic>)
          .map((e) => Movie.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result;
  }

  /// Fetch watchlist movies from TMDB
  Future<ApiResult<List<Movie>>> getWatchlistMovies({int page = 1}) async {
    final user = _getCurrentUser();
    if (user.isGuest) {
      return const ApiSuccess([]);
    }
    final endpoint = ApiConstants.watchlistMovies.replaceFirst(
      '{account_id}',
      user.id,
    );
    final result = await _apiClient.get(
      endpoint,
      queryParameters: {'session_id': user.sessionId, 'page': page},
      fromJson: (json) => (json['results'] as List<dynamic>)
          .map((e) => Movie.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result;
  }

  /// Mark or unmark a movie as favorite
  Future<ApiResult<bool>> markAsFavorite({
    required int movieId,
    required bool favorite,
  }) async {
    final user = _getCurrentUser();
    if (user.isGuest) {
      return const ApiError(message: 'Login required to favorite movies');
    }
    final endpoint = ApiConstants.markAsFavorite.replaceFirst(
      '{account_id}',
      user.id,
    );
    final result = await _apiClient.post(
      endpoint,
      queryParameters: {'session_id': user.sessionId},
      data: {'media_type': 'movie', 'media_id': movieId, 'favorite': favorite},
      fromJson: (json) =>
          json['status_code'] == 1 ||
          json['status_code'] == 12 ||
          json['status_code'] == 13,
    );
    return result;
  }

  /// Add or remove a movie from watchlist
  Future<ApiResult<bool>> addToWatchlist({
    required int movieId,
    required bool watchlist,
  }) async {
    final user = _getCurrentUser();
    if (user.isGuest) {
      return const ApiError(message: 'Login required to use watchlist');
    }
    final endpoint = ApiConstants.addToWatchlist.replaceFirst(
      '{account_id}',
      user.id,
    );
    final result = await _apiClient.post(
      endpoint,
      queryParameters: {'session_id': user.sessionId},
      data: {
        'media_type': 'movie',
        'media_id': movieId,
        'watchlist': watchlist,
      },
      fromJson: (json) =>
          json['status_code'] == 1 ||
          json['status_code'] == 12 ||
          json['status_code'] == 13,
    );
    return result;
  }
}

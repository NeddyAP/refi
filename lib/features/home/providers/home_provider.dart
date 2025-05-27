import 'package:flutter/foundation.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/movie.dart';
import '../../../shared/repositories/movie_repository.dart';

class HomeProvider extends ChangeNotifier {
  final MovieRepository _movieRepository;

  HomeProvider(this._movieRepository);

  // Popular movies
  ApiResult<MovieResponse>? _popularMovies;
  ApiResult<MovieResponse>? get popularMovies => _popularMovies;

  // Top rated movies
  ApiResult<MovieResponse>? _topRatedMovies;
  ApiResult<MovieResponse>? get topRatedMovies => _topRatedMovies;

  // Now playing movies
  ApiResult<MovieResponse>? _nowPlayingMovies;
  ApiResult<MovieResponse>? get nowPlayingMovies => _nowPlayingMovies;

  // Upcoming movies
  ApiResult<MovieResponse>? _upcomingMovies;
  ApiResult<MovieResponse>? get upcomingMovies => _upcomingMovies;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize home data
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Future.wait([
      loadPopularMovies(),
      loadTopRatedMovies(),
      loadNowPlayingMovies(),
      loadUpcomingMovies(),
    ]);

    _isInitialized = true;
  }

  /// Load popular movies
  Future<void> loadPopularMovies() async {
    _popularMovies = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getPopularMovies();
      _popularMovies = result;
    } catch (e) {
      _popularMovies = ApiError(message: 'Failed to load popular movies: $e');
    }
    
    notifyListeners();
  }

  /// Load top rated movies
  Future<void> loadTopRatedMovies() async {
    _topRatedMovies = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getTopRatedMovies();
      _topRatedMovies = result;
    } catch (e) {
      _topRatedMovies = ApiError(message: 'Failed to load top rated movies: $e');
    }
    
    notifyListeners();
  }

  /// Load now playing movies
  Future<void> loadNowPlayingMovies() async {
    _nowPlayingMovies = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getNowPlayingMovies();
      _nowPlayingMovies = result;
    } catch (e) {
      _nowPlayingMovies = ApiError(message: 'Failed to load now playing movies: $e');
    }
    
    notifyListeners();
  }

  /// Load upcoming movies
  Future<void> loadUpcomingMovies() async {
    _upcomingMovies = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getUpcomingMovies();
      _upcomingMovies = result;
    } catch (e) {
      _upcomingMovies = ApiError(message: 'Failed to load upcoming movies: $e');
    }
    
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    _isInitialized = false;
    await initialize();
  }

  /// Retry loading a specific section
  Future<void> retrySection(String section) async {
    switch (section) {
      case 'popular':
        await loadPopularMovies();
        break;
      case 'topRated':
        await loadTopRatedMovies();
        break;
      case 'nowPlaying':
        await loadNowPlayingMovies();
        break;
      case 'upcoming':
        await loadUpcomingMovies();
        break;
    }
  }
}

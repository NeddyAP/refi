import 'package:flutter/foundation.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/movie.dart';
import '../../../shared/models/tv_show.dart';
import '../../../shared/models/mixed_content.dart';
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

  // New content sections
  ApiResult<MixedContentResponse>? _trendingToday;
  ApiResult<MixedContentResponse>? get trendingToday => _trendingToday;

  ApiResult<MixedContentResponse>? _trendingThisWeek;
  ApiResult<MixedContentResponse>? get trendingThisWeek => _trendingThisWeek;

  ApiResult<MovieResponse>? _latestTrailers;
  ApiResult<MovieResponse>? get latestTrailers => _latestTrailers;

  ApiResult<MovieResponse>? _popularOnStreaming;
  ApiResult<MovieResponse>? get popularOnStreaming => _popularOnStreaming;

  ApiResult<TvShowResponse>? _popularOnTv;
  ApiResult<TvShowResponse>? get popularOnTv => _popularOnTv;

  ApiResult<MovieResponse>? _availableForRent;
  ApiResult<MovieResponse>? get availableForRent => _availableForRent;

  ApiResult<MovieResponse>? _currentlyInTheaters;
  ApiResult<MovieResponse>? get currentlyInTheaters => _currentlyInTheaters;

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
      loadTrendingToday(),
      loadTrendingThisWeek(),
      loadLatestTrailers(),
      loadPopularOnStreaming(),
      loadPopularOnTv(),
      loadAvailableForRent(),
      loadCurrentlyInTheaters(),
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

  /// Load trending today content
  Future<void> loadTrendingToday() async {
    _trendingToday = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getTrendingToday();
      _trendingToday = result;
    } catch (e) {
      _trendingToday = ApiError(message: 'Failed to load trending today: $e');
    }
    
    notifyListeners();
  }

  /// Load trending this week content
  Future<void> loadTrendingThisWeek() async {
    _trendingThisWeek = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getTrendingThisWeek();
      _trendingThisWeek = result;
    } catch (e) {
      _trendingThisWeek = ApiError(message: 'Failed to load trending this week: $e');
    }
    
    notifyListeners();
  }

  /// Load latest trailers
  Future<void> loadLatestTrailers() async {
    _latestTrailers = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getLatestTrailers();
      _latestTrailers = result;
    } catch (e) {
      _latestTrailers = ApiError(message: 'Failed to load latest trailers: $e');
    }
    
    notifyListeners();
  }

  /// Load popular on streaming content
  Future<void> loadPopularOnStreaming() async {
    _popularOnStreaming = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getPopularOnStreaming();
      _popularOnStreaming = result;
    } catch (e) {
      _popularOnStreaming = ApiError(message: 'Failed to load popular on streaming: $e');
    }
    
    notifyListeners();
  }

  /// Load popular on TV content
  Future<void> loadPopularOnTv() async {
    _popularOnTv = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getPopularOnTv();
      _popularOnTv = result;
    } catch (e) {
      _popularOnTv = ApiError(message: 'Failed to load popular on TV: $e');
    }
    
    notifyListeners();
  }

  /// Load available for rent content
  Future<void> loadAvailableForRent() async {
    _availableForRent = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getAvailableForRent();
      _availableForRent = result;
    } catch (e) {
      _availableForRent = ApiError(message: 'Failed to load available for rent: $e');
    }
    
    notifyListeners();
  }

  /// Load currently in theaters content
  Future<void> loadCurrentlyInTheaters() async {
    _currentlyInTheaters = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getCurrentlyInTheaters();
      _currentlyInTheaters = result;
    } catch (e) {
      _currentlyInTheaters = ApiError(message: 'Failed to load currently in theaters: $e');
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
      case 'trendingToday':
        await loadTrendingToday();
        break;
      case 'trendingThisWeek':
        await loadTrendingThisWeek();
        break;
      case 'latestTrailers':
        await loadLatestTrailers();
        break;
      case 'popularOnStreaming':
        await loadPopularOnStreaming();
        break;
      case 'popularOnTv':
        await loadPopularOnTv();
        break;
      case 'availableForRent':
        await loadAvailableForRent();
        break;
      case 'currentlyInTheaters':
        await loadCurrentlyInTheaters();
        break;
    }
  }
}

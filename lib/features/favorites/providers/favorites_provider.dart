import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../shared/models/movie.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/repositories/tmdb_account_repository.dart';
import '../../../core/network/api_result.dart';
import '../../../features/auth/services/tmdb_auth_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final TmdbAccountRepository _tmdbAccountRepository;

  FavoritesProvider(this._tmdbAccountRepository);

  List<Movie> _favoriteMovies = [];
  List<Movie> get favoriteMovies => _favoriteMovies;

  List<Movie> _watchlistMovies = [];
  List<Movie> get watchlistMovies => _watchlistMovies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize favorites data
  Future<void> initialize() async {
    if (_isInitialized) return;
    await refresh();
    _isInitialized = true;
  }

  /// Refresh favorites and watchlist from TMDB or local
  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    final user = TmdbAuthService().currentUser;
    if (user == null || user.isGuest) {
      await _loadFavoritesLocal();
      await _loadWatchlistLocal();
      _isLoading = false;
      notifyListeners();
      return;
    }
    // Authenticated: fetch from TMDB
    final favResult = await _tmdbAccountRepository.getFavoriteMovies();
    final watchResult = await _tmdbAccountRepository.getWatchlistMovies();
    favResult.when(
      success: (data) => _favoriteMovies = data,
      error: (msg, _) {
        _favoriteMovies = [];
        _errorMessage = msg;
      },
      loading: () {},
    );
    watchResult.when(
      success: (data) => _watchlistMovies = data,
      error: (msg, _) {
        _watchlistMovies = [];
        _errorMessage = msg;
      },
      loading: () {},
    );
    _isLoading = false;
    notifyListeners();
  }

  /// Pull-to-refresh
  Future<void> pullToRefresh() async => await refresh();

  /// Load favorites from local storage
  Future<void> _loadFavoritesLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson =
          prefs.getStringList(AppConstants.favoritesKey) ?? [];
      _favoriteMovies = favoritesJson
          .map((json) => Movie.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      _favoriteMovies = [];
      _errorMessage = 'Error loading favorites: $e';
    }
  }

  /// Load watchlist from local storage
  Future<void> _loadWatchlistLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlistJson =
          prefs.getStringList(AppConstants.watchlistKey) ?? [];
      _watchlistMovies = watchlistJson
          .map((json) => Movie.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      _watchlistMovies = [];
      _errorMessage = 'Error loading watchlist: $e';
    }
  }

  /// Save favorites to local storage
  Future<void> _saveFavoritesLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favoriteMovies
          .map((movie) => jsonEncode(movie.toJson()))
          .toList();
      await prefs.setStringList(AppConstants.favoritesKey, favoritesJson);
    } catch (e) {}
  }

  /// Save watchlist to local storage
  Future<void> _saveWatchlistLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlistJson = _watchlistMovies
          .map((movie) => jsonEncode(movie.toJson()))
          .toList();
      await prefs.setStringList(AppConstants.watchlistKey, watchlistJson);
    } catch (e) {}
  }

  /// Check if movie is in favorites
  bool isFavorite(int movieId) {
    return _favoriteMovies.any((movie) => movie.id == movieId);
  }

  /// Check if movie is in watchlist
  bool isInWatchlist(int movieId) {
    return _watchlistMovies.any((movie) => movie.id == movieId);
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(Movie movie) async {
    final user = TmdbAuthService().currentUser;
    if (user == null || user.isGuest) {
      // Local
      if (isFavorite(movie.id)) {
        _favoriteMovies.removeWhere((m) => m.id == movie.id);
      } else {
        _favoriteMovies.add(movie);
      }
      await _saveFavoritesLocal();
      notifyListeners();
      return;
    }
    // Remote
    final result = await _tmdbAccountRepository.markAsFavorite(
      movieId: movie.id,
      favorite: !isFavorite(movie.id),
    );
    if (result.isSuccess) {
      if (isFavorite(movie.id)) {
        _favoriteMovies.removeWhere((m) => m.id == movie.id);
      } else {
        _favoriteMovies.add(movie);
      }
    } else if (result.isError) {
      _errorMessage = result.errorMessage;
    }
    notifyListeners();
  }

  /// Remove movie from favorites
  Future<void> removeFromFavorites(int movieId) async {
    final user = TmdbAuthService().currentUser;
    if (user == null || user.isGuest) {
      _favoriteMovies.removeWhere((movie) => movie.id == movieId);
      await _saveFavoritesLocal();
      notifyListeners();
      return;
    }
    final result = await _tmdbAccountRepository.markAsFavorite(
      movieId: movieId,
      favorite: false,
    );
    if (result.isSuccess) {
      _favoriteMovies.removeWhere((movie) => movie.id == movieId);
    } else if (result.isError) {
      _errorMessage = result.errorMessage;
    }
    notifyListeners();
  }

  /// Toggle watchlist status
  Future<void> toggleWatchlist(Movie movie) async {
    final user = TmdbAuthService().currentUser;
    if (user == null || user.isGuest) {
      if (isInWatchlist(movie.id)) {
        _watchlistMovies.removeWhere((m) => m.id == movie.id);
      } else {
        _watchlistMovies.add(movie);
      }
      await _saveWatchlistLocal();
      notifyListeners();
      return;
    }
    final result = await _tmdbAccountRepository.addToWatchlist(
      movieId: movie.id,
      watchlist: !isInWatchlist(movie.id),
    );
    if (result.isSuccess) {
      if (isInWatchlist(movie.id)) {
        _watchlistMovies.removeWhere((m) => m.id == movie.id);
      } else {
        _watchlistMovies.add(movie);
      }
    } else if (result.isError) {
      _errorMessage = result.errorMessage;
    }
    notifyListeners();
  }

  /// Remove movie from watchlist
  Future<void> removeFromWatchlist(int movieId) async {
    final user = TmdbAuthService().currentUser;
    if (user == null || user.isGuest) {
      _watchlistMovies.removeWhere((movie) => movie.id == movieId);
      await _saveWatchlistLocal();
      notifyListeners();
      return;
    }
    final result = await _tmdbAccountRepository.addToWatchlist(
      movieId: movieId,
      watchlist: false,
    );
    if (result.isSuccess) {
      _watchlistMovies.removeWhere((movie) => movie.id == movieId);
    } else if (result.isError) {
      _errorMessage = result.errorMessage;
    }
    notifyListeners();
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    _favoriteMovies.clear();
    await _saveFavoritesLocal();
    notifyListeners();
  }

  /// Clear all watchlist
  Future<void> clearWatchlist() async {
    _watchlistMovies.clear();
    await _saveWatchlistLocal();
    notifyListeners();
  }

  /// Get total count
  int get totalCount => _favoriteMovies.length + _watchlistMovies.length;
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../shared/models/movie.dart';
import '../../../core/constants/app_constants.dart';

class FavoritesProvider extends ChangeNotifier {
  List<Movie> _favoriteMovies = [];
  List<Movie> get favoriteMovies => _favoriteMovies;

  List<Movie> _watchlistMovies = [];
  List<Movie> get watchlistMovies => _watchlistMovies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize favorites data
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    await _loadFavorites();
    await _loadWatchlist();

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  /// Load favorites from local storage
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(AppConstants.favoritesKey) ?? [];
      
      _favoriteMovies = favoritesJson
          .map((json) => Movie.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading favorites: $e');
      _favoriteMovies = [];
    }
  }

  /// Load watchlist from local storage
  Future<void> _loadWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlistJson = prefs.getStringList(AppConstants.watchlistKey) ?? [];
      
      _watchlistMovies = watchlistJson
          .map((json) => Movie.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading watchlist: $e');
      _watchlistMovies = [];
    }
  }

  /// Save favorites to local storage
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favoriteMovies
          .map((movie) => jsonEncode(movie.toJson()))
          .toList();
      
      await prefs.setStringList(AppConstants.favoritesKey, favoritesJson);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  /// Save watchlist to local storage
  Future<void> _saveWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlistJson = _watchlistMovies
          .map((movie) => jsonEncode(movie.toJson()))
          .toList();
      
      await prefs.setStringList(AppConstants.watchlistKey, watchlistJson);
    } catch (e) {
      print('Error saving watchlist: $e');
    }
  }

  /// Check if movie is in favorites
  bool isFavorite(int movieId) {
    return _favoriteMovies.any((movie) => movie.id == movieId);
  }

  /// Check if movie is in watchlist
  bool isInWatchlist(int movieId) {
    return _watchlistMovies.any((movie) => movie.id == movieId);
  }

  /// Add movie to favorites
  Future<void> addToFavorites(Movie movie) async {
    if (!isFavorite(movie.id)) {
      _favoriteMovies.add(movie);
      await _saveFavorites();
      notifyListeners();
    }
  }

  /// Remove movie from favorites
  Future<void> removeFromFavorites(int movieId) async {
    _favoriteMovies.removeWhere((movie) => movie.id == movieId);
    await _saveFavorites();
    notifyListeners();
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie.id)) {
      await removeFromFavorites(movie.id);
    } else {
      await addToFavorites(movie);
    }
  }

  /// Add movie to watchlist
  Future<void> addToWatchlist(Movie movie) async {
    if (!isInWatchlist(movie.id)) {
      _watchlistMovies.add(movie);
      await _saveWatchlist();
      notifyListeners();
    }
  }

  /// Remove movie from watchlist
  Future<void> removeFromWatchlist(int movieId) async {
    _watchlistMovies.removeWhere((movie) => movie.id == movieId);
    await _saveWatchlist();
    notifyListeners();
  }

  /// Toggle watchlist status
  Future<void> toggleWatchlist(Movie movie) async {
    if (isInWatchlist(movie.id)) {
      await removeFromWatchlist(movie.id);
    } else {
      await addToWatchlist(movie);
    }
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    _favoriteMovies.clear();
    await _saveFavorites();
    notifyListeners();
  }

  /// Clear all watchlist
  Future<void> clearWatchlist() async {
    _watchlistMovies.clear();
    await _saveWatchlist();
    notifyListeners();
  }

  /// Get total count
  int get totalCount => _favoriteMovies.length + _watchlistMovies.length;
}

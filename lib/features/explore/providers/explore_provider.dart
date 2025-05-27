import 'package:flutter/foundation.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/movie.dart';
import '../../../shared/models/genre.dart';
import '../../../shared/repositories/movie_repository.dart';

class ExploreProvider extends ChangeNotifier {
  final MovieRepository _movieRepository;

  ExploreProvider(this._movieRepository);

  // Search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  ApiResult<MovieResponse>? _searchResults;
  ApiResult<MovieResponse>? get searchResults => _searchResults;

  // Genres
  ApiResult<GenreResponse>? _genres;
  ApiResult<GenreResponse>? get genres => _genres;

  Genre? _selectedGenre;
  Genre? get selectedGenre => _selectedGenre;

  ApiResult<MovieResponse>? _genreMovies;
  ApiResult<MovieResponse>? get genreMovies => _genreMovies;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize explore data
  Future<void> initialize() async {
    if (_isInitialized) return;

    await loadGenres();
    _isInitialized = true;
  }

  /// Load genres
  Future<void> loadGenres() async {
    _genres = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getGenres();
      _genres = result;
    } catch (e) {
      _genres = ApiError(message: 'Failed to load genres: $e');
    }
    
    notifyListeners();
  }

  /// Search movies
  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      _searchQuery = '';
      _searchResults = null;
      notifyListeners();
      return;
    }

    _searchQuery = query;
    _searchResults = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.searchMovies(query);
      _searchResults = result;
    } catch (e) {
      _searchResults = ApiError(message: 'Failed to search movies: $e');
    }
    
    notifyListeners();
  }

  /// Select genre and load movies
  Future<void> selectGenre(Genre? genre) async {
    _selectedGenre = genre;
    
    if (genre == null) {
      _genreMovies = null;
      notifyListeners();
      return;
    }

    _genreMovies = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getMoviesByGenre(genre.id);
      _genreMovies = result;
    } catch (e) {
      _genreMovies = ApiError(message: 'Failed to load movies for ${genre.name}: $e');
    }
    
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults = null;
    notifyListeners();
  }

  /// Clear genre selection
  void clearGenreSelection() {
    _selectedGenre = null;
    _genreMovies = null;
    notifyListeners();
  }

  /// Retry search
  Future<void> retrySearch() async {
    if (_searchQuery.isNotEmpty) {
      await searchMovies(_searchQuery);
    }
  }

  /// Retry genre movies
  Future<void> retryGenreMovies() async {
    if (_selectedGenre != null) {
      await selectGenre(_selectedGenre);
    }
  }

  /// Retry genres
  Future<void> retryGenres() async {
    await loadGenres();
  }
}

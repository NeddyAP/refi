import 'package:flutter/foundation.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/movie.dart';
import '../../../shared/models/genre.dart';
import '../../../shared/models/advanced_search_params.dart';
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

  // Advanced Search
  AdvancedSearchParams _advancedSearchParams = const AdvancedSearchParams();
  AdvancedSearchParams get advancedSearchParams => _advancedSearchParams;

  ApiResult<MovieResponse>? _advancedSearchResults;
  ApiResult<MovieResponse>? get advancedSearchResults => _advancedSearchResults;

  // Advanced search filter states
  List<int> _selectedGenreIds = [];
  List<int> get selectedGenreIds => _selectedGenreIds;

  int? _selectedReleaseYear;
  int? get selectedReleaseYear => _selectedReleaseYear;

  int? _releaseYearStart;
  int? get releaseYearStart => _releaseYearStart;

  int? _releaseYearEnd;
  int? get releaseYearEnd => _releaseYearEnd;

  double? _ratingMin;
  double? get ratingMin => _ratingMin;

  double? _ratingMax;
  double? get ratingMax => _ratingMax;

  int? _minVoteCount;
  int? get minVoteCount => _minVoteCount;

  String? _selectedLanguage;
  String? get selectedLanguage => _selectedLanguage;

  String _sortBy = 'popularity.desc';
  String get sortBy => _sortBy;

  int? _runtimeMin;
  int? get runtimeMin => _runtimeMin;

  int? _runtimeMax;
  int? get runtimeMax => _runtimeMax;

  bool _isAdvancedSearchMode = false;
  bool get isAdvancedSearchMode => _isAdvancedSearchMode;

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

  /// Search movies by genre name
  Future<void> searchMoviesByGenre(String genreName) async {
    // First load genres if not already loaded
    if (_genres == null) {
      await loadGenres();
    }
    
    _genres?.when(
      success: (genreResponse) {
        // Find the genre by name (case insensitive)
        final genre = genreResponse.genres.firstWhere(
          (g) => g.name.toLowerCase() == genreName.toLowerCase(),
          orElse: () => Genre(id: -1, name: genreName), // Create a placeholder if not found
        );
        
        if (genre.id != -1) {
          selectGenre(genre);
        } else {
          // If genre not found, perform a text search instead
          searchMovies(genreName);
        }
      },
      error: (_, __) {
        // If genres failed to load, perform a text search instead
        searchMovies(genreName);
      },
      loading: () {
        // If still loading, we'll try again after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          searchMoviesByGenre(genreName);
        });
      },
    );
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

  // Advanced Search Methods

  /// Toggle advanced search mode
  void toggleAdvancedSearchMode() {
    _isAdvancedSearchMode = !_isAdvancedSearchMode;
    if (!_isAdvancedSearchMode) {
      clearAdvancedSearch();
    }
    notifyListeners();
  }

  /// Update selected genre IDs for advanced search
  void updateSelectedGenres(List<int> genreIds) {
    _selectedGenreIds = List.from(genreIds);
    _updateAdvancedSearchParams();
  }

  /// Update release year for advanced search
  void updateReleaseYear(int? year) {
    _selectedReleaseYear = year;
    _releaseYearStart = null;
    _releaseYearEnd = null;
    _updateAdvancedSearchParams();
  }

  /// Update release year range for advanced search
  void updateReleaseYearRange(int? startYear, int? endYear) {
    _releaseYearStart = startYear;
    _releaseYearEnd = endYear;
    _selectedReleaseYear = null;
    _updateAdvancedSearchParams();
  }

  /// Update rating range for advanced search
  void updateRatingRange(double? minRating, double? maxRating) {
    _ratingMin = minRating;
    _ratingMax = maxRating;
    _updateAdvancedSearchParams();
  }

  /// Update minimum vote count for advanced search
  void updateMinVoteCount(int? voteCount) {
    _minVoteCount = voteCount;
    _updateAdvancedSearchParams();
  }

  /// Update selected language for advanced search
  void updateSelectedLanguage(String? language) {
    _selectedLanguage = language;
    _updateAdvancedSearchParams();
  }

  /// Update sort order for advanced search
  void updateSortBy(String sortBy) {
    _sortBy = sortBy;
    _updateAdvancedSearchParams();
  }

  /// Update runtime range for advanced search
  void updateRuntimeRange(int? minRuntime, int? maxRuntime) {
    _runtimeMin = minRuntime;
    _runtimeMax = maxRuntime;
    _updateAdvancedSearchParams();
  }

  /// Update advanced search parameters and rebuild params object
  void _updateAdvancedSearchParams() {
    _advancedSearchParams = AdvancedSearchParams(
      genreIds: _selectedGenreIds.isNotEmpty ? _selectedGenreIds : null,
      releaseYear: _selectedReleaseYear,
      releaseYearStart: _releaseYearStart,
      releaseYearEnd: _releaseYearEnd,
      ratingMin: _ratingMin,
      ratingMax: _ratingMax,
      minVoteCount: _minVoteCount,
      originalLanguage: _selectedLanguage,
      runtimeMin: _runtimeMin,
      runtimeMax: _runtimeMax,
      sortBy: _sortBy,
      page: 1,
    );
    notifyListeners();
  }

  /// Perform advanced search with current parameters
  Future<void> performAdvancedSearch() async {
    if (_advancedSearchParams.isEmpty) {
      _advancedSearchResults = null;
      notifyListeners();
      return;
    }

    _advancedSearchResults = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.discoverMovies(_advancedSearchParams);
      _advancedSearchResults = result;
    } catch (e) {
      _advancedSearchResults = ApiError(message: 'Failed to perform advanced search: $e');
    }

    notifyListeners();
  }

  /// Load more results for advanced search (pagination)
  Future<void> loadMoreAdvancedSearchResults() async {
    if (_advancedSearchResults == null) return;

    _advancedSearchResults?.when(
      success: (currentResponse) async {
        if (currentResponse.page >= currentResponse.totalPages) return;

        final nextPageParams = _advancedSearchParams.copyWith(
          page: currentResponse.page + 1,
        );

        try {
          final result = await _movieRepository.discoverMovies(nextPageParams);
          result.when(
            success: (newResponse) {
              final combinedMovies = [
                ...currentResponse.results,
                ...newResponse.results,
              ];
              final combinedResponse = MovieResponse(
                page: newResponse.page,
                results: combinedMovies,
                totalPages: newResponse.totalPages,
                totalResults: newResponse.totalResults,
              );
              _advancedSearchResults = ApiSuccess(combinedResponse);
              notifyListeners();
            },
            error: (message, code) {
              // Keep existing results but could show a toast or error indicator
            },
            loading: () {},
          );
        } catch (e) {
          // Keep existing results on pagination error
        }
      },
      error: (_, __) {},
      loading: () {},
    );
  }

  /// Clear advanced search parameters and results
  void clearAdvancedSearch() {
    _selectedGenreIds.clear();
    _selectedReleaseYear = null;
    _releaseYearStart = null;
    _releaseYearEnd = null;
    _ratingMin = null;
    _ratingMax = null;
    _minVoteCount = null;
    _selectedLanguage = null;
    _sortBy = 'popularity.desc';
    _runtimeMin = null;
    _runtimeMax = null;
    _advancedSearchParams = const AdvancedSearchParams();
    _advancedSearchResults = null;
    notifyListeners();
  }

  /// Retry advanced search with current parameters
  Future<void> retryAdvancedSearch() async {
    if (!_advancedSearchParams.isEmpty) {
      await performAdvancedSearch();
    }
  }

  /// Check if any advanced search filters are applied
  bool get hasAdvancedFilters {
    return !_advancedSearchParams.isEmpty;
  }

  /// Get a summary of applied filters for display
  String get appliedFiltersDescription {
    List<String> filters = [];

    if (_selectedGenreIds.isNotEmpty) {
      filters.add('${_selectedGenreIds.length} genre(s)');
    }

    if (_selectedReleaseYear != null) {
      filters.add('Year: $_selectedReleaseYear');
    } else if (_releaseYearStart != null || _releaseYearEnd != null) {
      if (_releaseYearStart != null && _releaseYearEnd != null) {
        filters.add('Years: $_releaseYearStart-$_releaseYearEnd');
      } else if (_releaseYearStart != null) {
        filters.add('From: $_releaseYearStart');
      } else {
        filters.add('Until: $_releaseYearEnd');
      }
    }

    if (_ratingMin != null || _ratingMax != null) {
      if (_ratingMin != null && _ratingMax != null) {
        filters.add('Rating: $_ratingMin-$_ratingMax');
      } else if (_ratingMin != null) {
        filters.add('Rating ≥ $_ratingMin');
      } else {
        filters.add('Rating ≤ $_ratingMax');
      }
    }

    if (_selectedLanguage != null) {
      filters.add('Language: $_selectedLanguage');
    }

    if (_runtimeMin != null || _runtimeMax != null) {
      if (_runtimeMin != null && _runtimeMax != null) {
        filters.add('Runtime: $_runtimeMin-$_runtimeMax min');
      } else if (_runtimeMin != null) {
        filters.add('Runtime ≥ $_runtimeMin min');
      } else {
        filters.add('Runtime ≤ $_runtimeMax min');
      }
    }

    return filters.isEmpty ? 'No filters applied' : filters.join(', ');
  }
}

import 'package:flutter/foundation.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/movie_details.dart';
import '../../../shared/repositories/movie_repository.dart';

class MovieDetailsProvider extends ChangeNotifier {
  final MovieRepository _movieRepository;
  final int movieId;

  MovieDetailsProvider(this._movieRepository, this.movieId);

  ApiResult<MovieDetails>? _movieDetails;
  ApiResult<MovieDetails>? get movieDetails => _movieDetails;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize movie details
  Future<void> initialize() async {
    if (_isInitialized) return;

    await loadMovieDetails();
    _isInitialized = true;
  }

  /// Load movie details
  Future<void> loadMovieDetails() async {
    _movieDetails = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getMovieDetails(movieId);
      _movieDetails = result;
    } catch (e) {
      _movieDetails = ApiError(message: 'Failed to load movie details: $e');
    }
    
    notifyListeners();
  }

  /// Retry loading movie details
  Future<void> retry() async {
    await loadMovieDetails();
  }
}

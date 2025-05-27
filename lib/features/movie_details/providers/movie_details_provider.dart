import 'package:flutter/foundation.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/movie_details.dart';
import '../../../shared/models/movie_video.dart';
import '../../../shared/models/movie_cast.dart';
import '../../../shared/models/movie_review.dart';
import '../../../shared/models/movie_images.dart';
import '../../../shared/repositories/movie_repository.dart';

class MovieDetailsProvider extends ChangeNotifier {
  final MovieRepository _movieRepository;
  final int movieId;

  MovieDetailsProvider(this._movieRepository, this.movieId);

  ApiResult<MovieDetails>? _movieDetails;
  ApiResult<MovieDetails>? get movieDetails => _movieDetails;

  ApiResult<MovieVideosResponse>? _movieVideos;
  ApiResult<MovieVideosResponse>? get movieVideos => _movieVideos;

  ApiResult<MovieCreditsResponse>? _movieCredits;
  ApiResult<MovieCreditsResponse>? get movieCredits => _movieCredits;

  ApiResult<MovieReviewsResponse>? _movieReviews;
  ApiResult<MovieReviewsResponse>? get movieReviews => _movieReviews;

  ApiResult<MovieImagesResponse>? _movieImages;
  ApiResult<MovieImagesResponse>? get movieImages => _movieImages;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize movie details
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load all movie data concurrently
    await Future.wait([
      loadMovieDetails(),
      loadMovieVideos(),
      loadMovieCredits(),
      loadMovieReviews(),
      loadMovieImages(),
    ]);
    
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

  /// Load movie videos
  Future<void> loadMovieVideos() async {
    _movieVideos = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getMovieVideos(movieId);
      _movieVideos = result;
    } catch (e) {
      _movieVideos = ApiError(message: 'Failed to load movie videos: $e');
    }
    
    notifyListeners();
  }

  /// Load movie credits (cast & crew)
  Future<void> loadMovieCredits() async {
    _movieCredits = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getMovieCredits(movieId);
      _movieCredits = result;
    } catch (e) {
      _movieCredits = ApiError(message: 'Failed to load movie credits: $e');
    }
    
    notifyListeners();
  }

  /// Load movie reviews
  Future<void> loadMovieReviews() async {
    _movieReviews = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getMovieReviews(movieId);
      _movieReviews = result;
    } catch (e) {
      _movieReviews = ApiError(message: 'Failed to load movie reviews: $e');
    }
    
    notifyListeners();
  }

  /// Load movie images
  Future<void> loadMovieImages() async {
    _movieImages = const ApiLoading();
    notifyListeners();

    try {
      final result = await _movieRepository.getMovieImages(movieId);
      _movieImages = result;
    } catch (e) {
      _movieImages = ApiError(message: 'Failed to load movie images: $e');
    }
    
    notifyListeners();
  }

  /// Retry loading all movie data
  Future<void> retry() async {
    await initialize();
  }

  /// Get trailers only
  List<MovieVideo> get trailers {
    return _movieVideos?.when(
      success: (videos) => videos.trailers,
      error: (_, __) => <MovieVideo>[],
      loading: () => <MovieVideo>[],
    ) ?? <MovieVideo>[];
  }

  /// Get top billed cast
  List<CastMember> get topBilledCast {
    return _movieCredits?.when(
      success: (credits) => credits.topBilledCast,
      error: (_, __) => <CastMember>[],
      loading: () => <CastMember>[],
    ) ?? <CastMember>[];
  }

  /// Get director
  CrewMember? get director {
    return _movieCredits?.when(
      success: (credits) => credits.director,
      error: (_, __) => null,
      loading: () => null,
    );
  }

  /// Get movie reviews list
  List<MovieReview> get reviews {
    return _movieReviews?.when(
      success: (reviews) => reviews.results,
      error: (_, __) => <MovieReview>[],
      loading: () => <MovieReview>[],
    ) ?? <MovieReview>[];
  }

  /// Get movie backdrops
  List<MovieImage> get backdrops {
    return _movieImages?.when(
      success: (images) => images.backdrops,
      error: (_, __) => <MovieImage>[],
      loading: () => <MovieImage>[],
    ) ?? <MovieImage>[];
  }

  /// Get movie posters
  List<MovieImage> get posters {
    return _movieImages?.when(
      success: (images) => images.posters,
      error: (_, __) => <MovieImage>[],
      loading: () => <MovieImage>[],
    ) ?? <MovieImage>[];
  }
}

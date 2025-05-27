class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';
  
  // Image sizes
  static const String posterSizeW185 = '/w185';
  static const String posterSizeW342 = '/w342';
  static const String posterSizeW500 = '/w500';
  static const String posterSizeW780 = '/w780';
  static const String posterSizeOriginal = '/original';
  
  static const String backdropSizeW300 = '/w300';
  static const String backdropSizeW780 = '/w780';
  static const String backdropSizeW1280 = '/w1280';
  static const String backdropSizeOriginal = '/original';
  
  // Endpoints
  static const String popularMovies = '/movie/popular';
  static const String topRatedMovies = '/movie/top_rated';
  static const String upcomingMovies = '/movie/upcoming';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String searchMovies = '/search/movie';
  static const String movieDetails = '/movie';
  static const String movieCredits = '/credits';
  static const String movieVideos = '/videos';
  static const String movieReviews = '/reviews';
  static const String genres = '/genre/movie/list';
  
  // Query parameters
  static const String apiKeyParam = 'api_key';
  static const String languageParam = 'language';
  static const String pageParam = 'page';
  static const String queryParam = 'query';
  static const String genreParam = 'with_genres';
  static const String yearParam = 'year';
  static const String sortByParam = 'sort_by';
  
  // Default values
  static const String defaultLanguage = 'en-US';
  static const int defaultPage = 1;
  static const int itemsPerPage = 20;
  
  // Request timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}

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
  static const String movieImages = '/images';
  static const String genres = '/genre/movie/list';

  // New endpoints for enhanced home screen
  static const String trendingAll = '/trending/all'; // For trending today/week
  static const String trendingMovies = '/trending/movie'; // For trending movies
  static const String trendingTv = '/trending/tv'; // For trending TV shows
  static const String discoverMovie =
      '/discover/movie'; // For filtered movie discovery
  static const String discoverTv = '/discover/tv'; // For TV show discovery
  static const String popularTv = '/tv/popular'; // For Popular On TV
  static const String onTheAirTv = '/tv/on_the_air'; // For Currently On Air TV
  static const String watchProviders =
      '/watch/providers'; // For streaming providers

  // Query parameters
  static const String apiKeyParam = 'api_key';
  static const String languageParam = 'language';
  static const String pageParam = 'page';
  static const String queryParam = 'query';
  static const String genreParam = 'with_genres';
  static const String yearParam = 'year';
  static const String sortByParam = 'sort_by';
  static const String timeWindowParam = 'time_window';
  static const String withWatchProvidersParam = 'with_watch_providers';
  static const String watchRegionParam = 'watch_region';
  static const String releaseDateGteParam = 'release_date.gte';
  static const String releaseDateLteParam = 'release_date.lte';
  static const String withWatchMonetizationTypesParam =
      'with_watch_monetization_types';

  // Advanced search parameters for /discover/movie endpoint
  static const String primaryReleaseYearParam = 'primary_release_year';
  static const String primaryReleaseDateGteParam = 'primary_release_date.gte';
  static const String primaryReleaseDateLteParam = 'primary_release_date.lte';
  static const String voteAverageGteParam = 'vote_average.gte';
  static const String voteAverageLteParam = 'vote_average.lte';
  static const String voteCountGteParam = 'vote_count.gte';
  static const String withOriginalLanguageParam = 'with_original_language';
  static const String withoutGenresParam = 'without_genres';
  static const String withKeywordsParam = 'with_keywords';
  static const String withoutKeywordsParam = 'without_keywords';
  static const String withRuntimeGteParam = 'with_runtime.gte';
  static const String withRuntimeLteParam = 'with_runtime.lte';
  static const String certificationParam = 'certification';
  static const String certificationCountryParam = 'certification_country';
  static const String includeAdultParam = 'include_adult';
  static const String includeVideoParam = 'include_video';

  // Default values
  static const String defaultLanguage = 'en-US';
  static const int defaultPage = 1;
  static const int itemsPerPage = 20;

  // Request timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // TMDB Account endpoints
  static const String account = '/account';
  static const String favoriteMovies = '/account/{account_id}/favorite/movies';
  static const String watchlistMovies =
      '/account/{account_id}/watchlist/movies';
  static const String markAsFavorite = '/account/{account_id}/favorite';
  static const String addToWatchlist = '/account/{account_id}/watchlist';
}

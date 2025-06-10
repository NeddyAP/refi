class AppConstants {
  // App info
  static const String appName = 'Refi';
  static const String appVersion = '1.0.0';

  // Navigation
  static const String homeRoute = '/home';
  static const String exploreRoute = '/explore';
  static const String favoritesRoute = '/favorites';
  static const String profileRoute = '/profile';
  static const String movieDetailsRoute = '/movie';
  static const String allItemsRoute = '/all-items';
  static const String searchRoute = '/search';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String accountInfoRoute = '/profile/account-info';
  static const String privacySettingsRoute = '/profile/privacy';
  static const String notificationSettingsRoute = '/profile/notifications';
  static const String languageSettingsRoute = '/profile/language';
  static const String onboardingRoute = '/onboarding';

  // Storage keys
  static const String userTokenKey = 'user_token';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String userDataKey = 'user_data';
  static const String favoritesKey = 'favorites';
  static const String watchlistKey = 'watchlist';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Database
  static const String databaseName = 'refi_database.db';
  static const int databaseVersion = 1;

  // Tables
  static const String moviesTable = 'movies';
  static const String favoritesTable = 'favorites';
  static const String reviewsTable = 'reviews';
  static const String usersTable = 'users';

  // Limits
  static const int maxReviewLength = 500;
  static const int maxSearchHistory = 10;
  static const int cacheExpiryHours = 24;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;

  // Animation durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // Rating
  static const int maxRating = 5;
  static const double minRating = 0.5;

  // Pagination
  static const int itemsPerPage = 20;
  static const int preloadThreshold = 5;
}

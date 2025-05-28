// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Refi';

  @override
  String get profileScreenTitle => 'Profile';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutDialogTitle => 'Sign Out';

  @override
  String get signOutDialogContent => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get guestUser => 'Guest User';

  @override
  String get browsingAsGuest => 'Browsing as guest';

  @override
  String get tmdbUser => 'TMDB User';

  @override
  String get guestSession => 'Guest Session';

  @override
  String get tmdbAccount => 'TMDB Account';

  @override
  String get joined => 'Joined';

  @override
  String get language => 'Language';

  @override
  String get region => 'Region';

  @override
  String get adult => 'Adult';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get viewAccountInfo => 'View Account Info';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUpAtTmdb => 'Sign Up at TMDB';

  @override
  String couldNotOpen(String url) {
    return 'Could not open $url';
  }

  @override
  String get settings => 'Settings';

  @override
  String get appLanguage => 'App Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkThemeEnabled => 'Dark theme enabled';

  @override
  String get lightThemeEnabled => 'Light theme enabled';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get guest => 'Guest';

  @override
  String hiUserGreeting(String userName) {
    return 'Hi, $userName!';
  }

  @override
  String get profileAndSettings => 'Profile & Settings';

  @override
  String get whatMovieDoYouWantToSee => 'what movie do you want to see?';

  @override
  String get findTheMovieYouLike => 'find the movie you like';

  @override
  String get frequentlyVisited => 'Frequently Visited';

  @override
  String get trendingToday => 'Trending Today';

  @override
  String get trendingThisWeek => 'Trending This Week';

  @override
  String get latestTrailers => 'Latest Trailers';

  @override
  String get popularOnStreaming => 'Popular on Streaming';

  @override
  String get popularOnTv => 'Popular On TV';

  @override
  String get availableForRent => 'Available For Rent';

  @override
  String get currentlyInTheaters => 'Currently In Theaters';

  @override
  String get family => 'Family';

  @override
  String get loadingMovieDetails => 'Loading movie details...';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get addedToWatchlist => 'Added to watchlist';

  @override
  String get removedFromWatchlist => 'Removed from watchlist';

  @override
  String get removeFromWatchlist => 'Remove from watchlist';

  @override
  String get addToWatchlist => 'Add to watchlist';

  @override
  String get noOverviewAvailable => 'No overview available.';

  @override
  String get trailers => 'Trailers';

  @override
  String get topBilledCast => 'Top Billed Cast';

  @override
  String get fullCastAndCrew => 'Full Cast & Crew';

  @override
  String get director => 'Director';

  @override
  String get writers => 'Writers';

  @override
  String get viewFullCastAndCrew => 'View Full Cast & Crew';

  @override
  String get crew => 'Crew';

  @override
  String get userReviews => 'User Reviews';

  @override
  String viewAllReviews(int count) {
    return 'View All Reviews ($count)';
  }

  @override
  String allReviews(int count) {
    return 'All Reviews ($count)';
  }

  @override
  String get media => 'Media';

  @override
  String get backdrops => 'Backdrops';

  @override
  String get posters => 'Posters';

  @override
  String imageGalleryTitle(int current, int total) {
    return '$current of $total';
  }

  @override
  String get exploreScreenTitle => 'Explore';

  @override
  String get searchMoviesHint => 'Search movies...';

  @override
  String get advancedSearchActive => 'Advanced search active';

  @override
  String get exitAdvancedSearch => 'Exit advanced search';

  @override
  String get advancedSearch => 'Advanced search';

  @override
  String get advancedSearchTitle => 'Advanced Search';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get genres => 'Genres';

  @override
  String failedToLoadGenres(String message) {
    return 'Failed to load genres: $message';
  }

  @override
  String get releaseYear => 'Release Year';

  @override
  String get fromYear => 'From Year';

  @override
  String get toYear => 'To Year';

  @override
  String get ratingRange => 'Rating Range';

  @override
  String get minimumVoteCount => 'Minimum Vote Count';

  @override
  String get originalLanguage => 'Original Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get anyLanguage => 'Any Language';

  @override
  String get spanish => 'Spanish';

  @override
  String get french => 'French';

  @override
  String get german => 'German';

  @override
  String get italian => 'Italian';

  @override
  String get japanese => 'Japanese';

  @override
  String get korean => 'Korean';

  @override
  String get chinese => 'Chinese';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get russian => 'Russian';

  @override
  String get runtimeMinutes => 'Runtime (minutes)';

  @override
  String get minRuntime => 'Min Runtime';

  @override
  String get maxRuntime => 'Max Runtime';

  @override
  String get sortBy => 'Sort By';

  @override
  String get sortOrder => 'Sort Order';

  @override
  String get popularityHighToLow => 'Popularity (High to Low)';

  @override
  String get popularityLowToHigh => 'Popularity (Low to High)';

  @override
  String get releaseDateNewest => 'Release Date (Newest)';

  @override
  String get releaseDateOldest => 'Release Date (Oldest)';

  @override
  String get ratingHighToLow => 'Rating (High to Low)';

  @override
  String get ratingLowToHigh => 'Rating (Low to High)';

  @override
  String get voteCountHighToLow => 'Vote Count (High to Low)';

  @override
  String get revenueHighToLow => 'Revenue (High to Low)';

  @override
  String get noAdvancedSearchPerformed => 'No Advanced Search Performed';

  @override
  String get configureFiltersMessage =>
      'Configure your filters and search for movies.';

  @override
  String get popularMovies => 'Popular Movies';

  @override
  String get noMoviesAvailable => 'No Movies Available';

  @override
  String get unableToLoadPopularMovies =>
      'Unable to load popular movies at this time.';

  @override
  String get loadingText => 'Loading...';

  @override
  String get fetchingPopularMovies => 'Fetching popular movies for you.';

  @override
  String minRatingLabel(String rating) {
    return 'Min: $rating';
  }

  @override
  String maxRatingLabel(String rating) {
    return 'Max: $rating';
  }

  @override
  String minimumVotesLabel(int count) {
    return 'Minimum votes: $count';
  }

  @override
  String get favoritesScreenTitle => 'My Movies';

  @override
  String get favoritesTabTitle => 'Favorites';

  @override
  String get watchlistTabTitle => 'Watchlist';

  @override
  String get loadingYourMovies => 'Loading your movies...';

  @override
  String get noMoviesInWatchlistTitle => 'No Movies in Watchlist';

  @override
  String get noMoviesInWatchlistMessage =>
      'Add movies to your watchlist to keep track of what you want to watch.';

  @override
  String welcomeToApp(String appName) {
    return 'Welcome to $appName';
  }

  @override
  String get signInWithTmdbSubtitle =>
      'Sign in with your TMDB account to discover amazing movies';

  @override
  String get tmdbUsername => 'TMDB Username';

  @override
  String get enterTmdbUsername => 'Enter your TMDB username';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get signInWithTmdb => 'Sign In with TMDB';

  @override
  String get browseModeInfo => 'You can browse movies without signing in';

  @override
  String get signInBenefits => 'Sign in to rate movies and create watchlists';

  @override
  String get noTmdbAccount => 'Don\'t have a TMDB account? ';

  @override
  String get pleaseRegisterAt =>
      'Please register at https://www.themoviedb.org/signup';

  @override
  String get pleaseResetPasswordAt =>
      'Please reset your password at https://www.themoviedb.org/reset-password';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get enterTmdbUsernameValidation => 'Please enter your TMDB username';

  @override
  String get usernameMinLengthValidation =>
      'Username must be at least 3 characters';

  @override
  String get enterPasswordValidation => 'Please enter your password';

  @override
  String get passwordMinLengthValidation =>
      'Password must be at least 6 characters';

  @override
  String get signUpTitle => 'Sign Up';

  @override
  String get createTmdbAccount => 'Create TMDB Account';

  @override
  String createTmdbAccountDescription(String appName) {
    return 'To use all features of $appName, you need a TMDB account. Registration is free and takes just a minute.';
  }

  @override
  String get withTmdbAccountYouCan => 'With a TMDB account you can:';

  @override
  String get rateMoviesAndTvShows => 'Rate movies and TV shows';

  @override
  String get createAndManageWatchlists => 'Create and manage watchlists';

  @override
  String get markMoviesAsFavorites => 'Mark movies as favorites';

  @override
  String get syncAcrossDevices => 'Sync across all devices';

  @override
  String get registerAtTmdb => 'Register at TMDB';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get continueBrowsingAsGuest => 'Continue browsing as guest';

  @override
  String get pleaseVisitTmdbSignup =>
      'Please visit https://www.themoviedb.org/signup to register';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetYourPassword => 'Reset Your Password';

  @override
  String get resetPasswordDescription =>
      'To reset your TMDB account password, you need to visit the TMDB website.';

  @override
  String get howToResetPassword => 'How to reset your password:';

  @override
  String get visitTmdbResetPage => 'Visit the TMDB password reset page';

  @override
  String get enterUsernameOrEmail => 'Enter your TMDB username or email';

  @override
  String get checkEmailForInstructions =>
      'Check your email for reset instructions';

  @override
  String get returnToSignIn => 'Return here to sign in with your new password';

  @override
  String get resetPasswordAtTmdb => 'Reset Password at TMDB';

  @override
  String get backToSignIn => 'Back to Sign In';

  @override
  String get pleaseVisitTmdbResetPassword =>
      'Please visit https://www.themoviedb.org/reset-password to reset your password';

  @override
  String get homeLabel => 'Home';

  @override
  String get exploreLabel => 'Explore';

  @override
  String get favoritesLabel => 'Favorites';

  @override
  String get profileLabel => 'Profile';

  @override
  String get appTitleFull => 'Refi - Movie Recommendations';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get home => 'Home';

  @override
  String get explore => 'Explore';

  @override
  String get favorites => 'Favorites';

  @override
  String get profile => 'Profile';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get topRated => 'Top Rated';

  @override
  String get popular => 'Popular';

  @override
  String get viewAll => 'View All';

  @override
  String get searchMovies => 'Search movies...';

  @override
  String get movieDetails => 'Movie Details';

  @override
  String get overview => 'Overview';

  @override
  String get cast => 'Cast';

  @override
  String get reviews => 'Reviews';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get name => 'Name';

  @override
  String get changePassword => 'Change Password';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get allowPersonalization => 'Allow Personalization';

  @override
  String get allowNotifications => 'Allow Notifications';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get english => 'English';

  @override
  String get indonesian => 'Indonesian';

  @override
  String get logout => 'Logout';

  @override
  String get oopsSomethingWentWrong => 'Oops! Something went wrong.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get networkErrorMessage =>
      'Please check your internet connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get noResultsFoundTitle => 'No Results Found';

  @override
  String noResultsFoundMessage(String searchQuery) {
    return 'We couldn\'t find any movies matching \"$searchQuery\". Please try a different search term.';
  }

  @override
  String get noMoviesFoundGenericMessage =>
      'We couldn\'t find any movies at the moment. Please try again later.';

  @override
  String get clearSearchButton => 'Clear Search';

  @override
  String get noFavoritesYetTitle => 'No Favorites Yet';

  @override
  String get noFavoritesYetMessage =>
      'You haven\'t added any movies to your favorites. Start exploring and add some!';

  @override
  String get exploreMoviesButton => 'Explore Movies';

  @override
  String get pageNotFound => 'Page Not Found';

  @override
  String get pageNotFoundMessage =>
      'The page you are looking for does not exist.';

  @override
  String get goHome => 'Go Home';
}

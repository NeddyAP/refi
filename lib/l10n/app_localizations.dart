import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Refi'**
  String get appTitle;

  /// No description provided for @profileScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileScreenTitle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutDialogTitle;

  /// No description provided for @signOutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutDialogContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @browsingAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Browsing as guest'**
  String get browsingAsGuest;

  /// No description provided for @tmdbUser.
  ///
  /// In en, this message translates to:
  /// **'TMDB User'**
  String get tmdbUser;

  /// No description provided for @guestSession.
  ///
  /// In en, this message translates to:
  /// **'Guest Session'**
  String get guestSession;

  /// No description provided for @tmdbAccount.
  ///
  /// In en, this message translates to:
  /// **'TMDB Account'**
  String get tmdbAccount;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @adult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get adult;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @viewAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'View Account Info'**
  String get viewAccountInfo;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUpAtTmdb.
  ///
  /// In en, this message translates to:
  /// **'Sign Up at TMDB'**
  String get signUpAtTmdb;

  /// No description provided for @couldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String couldNotOpen(String url);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkThemeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dark theme enabled'**
  String get darkThemeEnabled;

  /// No description provided for @lightThemeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Light theme enabled'**
  String get lightThemeEnabled;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @hiUserGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {userName}!'**
  String hiUserGreeting(String userName);

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileAndSettings;

  /// No description provided for @whatMovieDoYouWantToSee.
  ///
  /// In en, this message translates to:
  /// **'what movie do you want to see?'**
  String get whatMovieDoYouWantToSee;

  /// No description provided for @findTheMovieYouLike.
  ///
  /// In en, this message translates to:
  /// **'find the movie you like'**
  String get findTheMovieYouLike;

  /// No description provided for @frequentlyVisited.
  ///
  /// In en, this message translates to:
  /// **'Frequently Visited'**
  String get frequentlyVisited;

  /// No description provided for @trendingToday.
  ///
  /// In en, this message translates to:
  /// **'Trending Today'**
  String get trendingToday;

  /// No description provided for @trendingThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Trending This Week'**
  String get trendingThisWeek;

  /// No description provided for @latestTrailers.
  ///
  /// In en, this message translates to:
  /// **'Latest Trailers'**
  String get latestTrailers;

  /// No description provided for @popularOnStreaming.
  ///
  /// In en, this message translates to:
  /// **'Popular on Streaming'**
  String get popularOnStreaming;

  /// No description provided for @popularOnTv.
  ///
  /// In en, this message translates to:
  /// **'Popular On TV'**
  String get popularOnTv;

  /// No description provided for @availableForRent.
  ///
  /// In en, this message translates to:
  /// **'Available For Rent'**
  String get availableForRent;

  /// No description provided for @currentlyInTheaters.
  ///
  /// In en, this message translates to:
  /// **'Currently In Theaters'**
  String get currentlyInTheaters;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @loadingMovieDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading movie details...'**
  String get loadingMovieDetails;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @addedToWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Added to watchlist'**
  String get addedToWatchlist;

  /// No description provided for @removedFromWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Removed from watchlist'**
  String get removedFromWatchlist;

  /// No description provided for @removeFromWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Remove from watchlist'**
  String get removeFromWatchlist;

  /// No description provided for @addToWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Add to watchlist'**
  String get addToWatchlist;

  /// No description provided for @noOverviewAvailable.
  ///
  /// In en, this message translates to:
  /// **'No overview available.'**
  String get noOverviewAvailable;

  /// No description provided for @trailers.
  ///
  /// In en, this message translates to:
  /// **'Trailers'**
  String get trailers;

  /// No description provided for @topBilledCast.
  ///
  /// In en, this message translates to:
  /// **'Top Billed Cast'**
  String get topBilledCast;

  /// No description provided for @fullCastAndCrew.
  ///
  /// In en, this message translates to:
  /// **'Full Cast & Crew'**
  String get fullCastAndCrew;

  /// No description provided for @director.
  ///
  /// In en, this message translates to:
  /// **'Director'**
  String get director;

  /// No description provided for @writers.
  ///
  /// In en, this message translates to:
  /// **'Writers'**
  String get writers;

  /// No description provided for @viewFullCastAndCrew.
  ///
  /// In en, this message translates to:
  /// **'View Full Cast & Crew'**
  String get viewFullCastAndCrew;

  /// No description provided for @crew.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get crew;

  /// No description provided for @userReviews.
  ///
  /// In en, this message translates to:
  /// **'User Reviews'**
  String get userReviews;

  /// No description provided for @viewAllReviews.
  ///
  /// In en, this message translates to:
  /// **'View All Reviews ({count})'**
  String viewAllReviews(int count);

  /// No description provided for @allReviews.
  ///
  /// In en, this message translates to:
  /// **'All Reviews ({count})'**
  String allReviews(int count);

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @backdrops.
  ///
  /// In en, this message translates to:
  /// **'Backdrops'**
  String get backdrops;

  /// No description provided for @posters.
  ///
  /// In en, this message translates to:
  /// **'Posters'**
  String get posters;

  /// No description provided for @imageGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String imageGalleryTitle(int current, int total);

  /// No description provided for @exploreScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreScreenTitle;

  /// No description provided for @searchMoviesHint.
  ///
  /// In en, this message translates to:
  /// **'Search movies...'**
  String get searchMoviesHint;

  /// No description provided for @advancedSearchActive.
  ///
  /// In en, this message translates to:
  /// **'Advanced search active'**
  String get advancedSearchActive;

  /// No description provided for @exitAdvancedSearch.
  ///
  /// In en, this message translates to:
  /// **'Exit advanced search'**
  String get exitAdvancedSearch;

  /// No description provided for @advancedSearch.
  ///
  /// In en, this message translates to:
  /// **'Advanced search'**
  String get advancedSearch;

  /// No description provided for @advancedSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Search'**
  String get advancedSearchTitle;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @failedToLoadGenres.
  ///
  /// In en, this message translates to:
  /// **'Failed to load genres: {message}'**
  String failedToLoadGenres(String message);

  /// No description provided for @releaseYear.
  ///
  /// In en, this message translates to:
  /// **'Release Year'**
  String get releaseYear;

  /// No description provided for @fromYear.
  ///
  /// In en, this message translates to:
  /// **'From Year'**
  String get fromYear;

  /// No description provided for @toYear.
  ///
  /// In en, this message translates to:
  /// **'To Year'**
  String get toYear;

  /// No description provided for @ratingRange.
  ///
  /// In en, this message translates to:
  /// **'Rating Range'**
  String get ratingRange;

  /// No description provided for @minimumVoteCount.
  ///
  /// In en, this message translates to:
  /// **'Minimum Vote Count'**
  String get minimumVoteCount;

  /// No description provided for @originalLanguage.
  ///
  /// In en, this message translates to:
  /// **'Original Language'**
  String get originalLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @anyLanguage.
  ///
  /// In en, this message translates to:
  /// **'Any Language'**
  String get anyLanguage;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @runtimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'Runtime (minutes)'**
  String get runtimeMinutes;

  /// No description provided for @minRuntime.
  ///
  /// In en, this message translates to:
  /// **'Min Runtime'**
  String get minRuntime;

  /// No description provided for @maxRuntime.
  ///
  /// In en, this message translates to:
  /// **'Max Runtime'**
  String get maxRuntime;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @sortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get sortOrder;

  /// No description provided for @popularityHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Popularity (High to Low)'**
  String get popularityHighToLow;

  /// No description provided for @popularityLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Popularity (Low to High)'**
  String get popularityLowToHigh;

  /// No description provided for @releaseDateNewest.
  ///
  /// In en, this message translates to:
  /// **'Release Date (Newest)'**
  String get releaseDateNewest;

  /// No description provided for @releaseDateOldest.
  ///
  /// In en, this message translates to:
  /// **'Release Date (Oldest)'**
  String get releaseDateOldest;

  /// No description provided for @ratingHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Rating (High to Low)'**
  String get ratingHighToLow;

  /// No description provided for @ratingLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Rating (Low to High)'**
  String get ratingLowToHigh;

  /// No description provided for @voteCountHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Vote Count (High to Low)'**
  String get voteCountHighToLow;

  /// No description provided for @revenueHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Revenue (High to Low)'**
  String get revenueHighToLow;

  /// No description provided for @noAdvancedSearchPerformed.
  ///
  /// In en, this message translates to:
  /// **'No Advanced Search Performed'**
  String get noAdvancedSearchPerformed;

  /// No description provided for @configureFiltersMessage.
  ///
  /// In en, this message translates to:
  /// **'Configure your filters and search for movies.'**
  String get configureFiltersMessage;

  /// No description provided for @popularMovies.
  ///
  /// In en, this message translates to:
  /// **'Popular Movies'**
  String get popularMovies;

  /// No description provided for @noMoviesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Movies Available'**
  String get noMoviesAvailable;

  /// No description provided for @unableToLoadPopularMovies.
  ///
  /// In en, this message translates to:
  /// **'Unable to load popular movies at this time.'**
  String get unableToLoadPopularMovies;

  /// No description provided for @loadingText.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingText;

  /// No description provided for @fetchingPopularMovies.
  ///
  /// In en, this message translates to:
  /// **'Fetching popular movies for you.'**
  String get fetchingPopularMovies;

  /// No description provided for @minRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Min: {rating}'**
  String minRatingLabel(String rating);

  /// No description provided for @maxRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Max: {rating}'**
  String maxRatingLabel(String rating);

  /// No description provided for @minimumVotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum votes: {count}'**
  String minimumVotesLabel(int count);

  /// No description provided for @favoritesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Movies'**
  String get favoritesScreenTitle;

  /// No description provided for @favoritesTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTabTitle;

  /// No description provided for @watchlistTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlistTabTitle;

  /// No description provided for @loadingYourMovies.
  ///
  /// In en, this message translates to:
  /// **'Loading your movies...'**
  String get loadingYourMovies;

  /// No description provided for @noMoviesInWatchlistTitle.
  ///
  /// In en, this message translates to:
  /// **'No Movies in Watchlist'**
  String get noMoviesInWatchlistTitle;

  /// No description provided for @noMoviesInWatchlistMessage.
  ///
  /// In en, this message translates to:
  /// **'Add movies to your watchlist to keep track of what you want to watch.'**
  String get noMoviesInWatchlistMessage;

  /// No description provided for @welcomeToApp.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {appName}'**
  String welcomeToApp(String appName);

  /// No description provided for @signInWithTmdbSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your TMDB account to discover amazing movies'**
  String get signInWithTmdbSubtitle;

  /// No description provided for @tmdbUsername.
  ///
  /// In en, this message translates to:
  /// **'TMDB Username'**
  String get tmdbUsername;

  /// No description provided for @enterTmdbUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your TMDB username'**
  String get enterTmdbUsername;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @signInWithTmdb.
  ///
  /// In en, this message translates to:
  /// **'Sign In with TMDB'**
  String get signInWithTmdb;

  /// No description provided for @browseModeInfo.
  ///
  /// In en, this message translates to:
  /// **'You can browse movies without signing in'**
  String get browseModeInfo;

  /// No description provided for @signInBenefits.
  ///
  /// In en, this message translates to:
  /// **'Sign in to rate movies and create watchlists'**
  String get signInBenefits;

  /// No description provided for @noTmdbAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have a TMDB account? '**
  String get noTmdbAccount;

  /// No description provided for @pleaseRegisterAt.
  ///
  /// In en, this message translates to:
  /// **'Please register at https://www.themoviedb.org/signup'**
  String get pleaseRegisterAt;

  /// No description provided for @pleaseResetPasswordAt.
  ///
  /// In en, this message translates to:
  /// **'Please reset your password at https://www.themoviedb.org/reset-password'**
  String get pleaseResetPasswordAt;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @enterTmdbUsernameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your TMDB username'**
  String get enterTmdbUsernameValidation;

  /// No description provided for @usernameMinLengthValidation.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLengthValidation;

  /// No description provided for @enterPasswordValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPasswordValidation;

  /// No description provided for @passwordMinLengthValidation.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLengthValidation;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpTitle;

  /// No description provided for @createTmdbAccount.
  ///
  /// In en, this message translates to:
  /// **'Create TMDB Account'**
  String get createTmdbAccount;

  /// No description provided for @createTmdbAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'To use all features of {appName}, you need a TMDB account. Registration is free and takes just a minute.'**
  String createTmdbAccountDescription(String appName);

  /// No description provided for @withTmdbAccountYouCan.
  ///
  /// In en, this message translates to:
  /// **'With a TMDB account you can:'**
  String get withTmdbAccountYouCan;

  /// No description provided for @rateMoviesAndTvShows.
  ///
  /// In en, this message translates to:
  /// **'Rate movies and TV shows'**
  String get rateMoviesAndTvShows;

  /// No description provided for @createAndManageWatchlists.
  ///
  /// In en, this message translates to:
  /// **'Create and manage watchlists'**
  String get createAndManageWatchlists;

  /// No description provided for @markMoviesAsFavorites.
  ///
  /// In en, this message translates to:
  /// **'Mark movies as favorites'**
  String get markMoviesAsFavorites;

  /// No description provided for @syncAcrossDevices.
  ///
  /// In en, this message translates to:
  /// **'Sync across all devices'**
  String get syncAcrossDevices;

  /// No description provided for @registerAtTmdb.
  ///
  /// In en, this message translates to:
  /// **'Register at TMDB'**
  String get registerAtTmdb;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @continueBrowsingAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue browsing as guest'**
  String get continueBrowsingAsGuest;

  /// No description provided for @pleaseVisitTmdbSignup.
  ///
  /// In en, this message translates to:
  /// **'Please visit https://www.themoviedb.org/signup to register'**
  String get pleaseVisitTmdbSignup;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get resetYourPassword;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'To reset your TMDB account password, you need to visit the TMDB website.'**
  String get resetPasswordDescription;

  /// No description provided for @howToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'How to reset your password:'**
  String get howToResetPassword;

  /// No description provided for @visitTmdbResetPage.
  ///
  /// In en, this message translates to:
  /// **'Visit the TMDB password reset page'**
  String get visitTmdbResetPage;

  /// No description provided for @enterUsernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your TMDB username or email'**
  String get enterUsernameOrEmail;

  /// No description provided for @checkEmailForInstructions.
  ///
  /// In en, this message translates to:
  /// **'Check your email for reset instructions'**
  String get checkEmailForInstructions;

  /// No description provided for @returnToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Return here to sign in with your new password'**
  String get returnToSignIn;

  /// No description provided for @resetPasswordAtTmdb.
  ///
  /// In en, this message translates to:
  /// **'Reset Password at TMDB'**
  String get resetPasswordAtTmdb;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @pleaseVisitTmdbResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Please visit https://www.themoviedb.org/reset-password to reset your password'**
  String get pleaseVisitTmdbResetPassword;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// No description provided for @exploreLabel.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreLabel;

  /// No description provided for @favoritesLabel.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesLabel;

  /// No description provided for @profileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileLabel;

  /// No description provided for @appTitleFull.
  ///
  /// In en, this message translates to:
  /// **'Refi - Movie Recommendations'**
  String get appTitleFull;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get topRated;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @searchMovies.
  ///
  /// In en, this message translates to:
  /// **'Search movies...'**
  String get searchMovies;

  /// No description provided for @movieDetails.
  ///
  /// In en, this message translates to:
  /// **'Movie Details'**
  String get movieDetails;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @cast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get cast;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @allowPersonalization.
  ///
  /// In en, this message translates to:
  /// **'Allow Personalization'**
  String get allowPersonalization;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get allowNotifications;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @oopsSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong.'**
  String get oopsSomethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @networkErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get networkErrorMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noResultsFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get noResultsFoundTitle;

  /// No description provided for @noResultsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any movies matching \"{searchQuery}\". Please try a different search term.'**
  String noResultsFoundMessage(String searchQuery);

  /// No description provided for @noMoviesFoundGenericMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any movies at the moment. Please try again later.'**
  String get noMoviesFoundGenericMessage;

  /// No description provided for @clearSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearchButton;

  /// No description provided for @noFavoritesYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get noFavoritesYetTitle;

  /// No description provided for @noFavoritesYetMessage.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any movies to your favorites. Start exploring and add some!'**
  String get noFavoritesYetMessage;

  /// No description provided for @exploreMoviesButton.
  ///
  /// In en, this message translates to:
  /// **'Explore Movies'**
  String get exploreMoviesButton;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get pageNotFound;

  /// No description provided for @pageNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The page you are looking for does not exist.'**
  String get pageNotFoundMessage;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

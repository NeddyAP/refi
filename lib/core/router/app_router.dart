import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/favorites/screens/favorites_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/movie_details/screens/movie_details_screen.dart';
import '../../features/movie_details/providers/movie_details_provider.dart';
import '../../features/home/screens/all_items_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/bottom_navigation.dart';
import '../../shared/repositories/movie_repository.dart';
import '../constants/app_constants.dart';
import '../../features/profile/screens/account_info_screen.dart';
import '../../features/profile/screens/privacy_settings_screen.dart';
import '../../features/profile/screens/language_settings_screen.dart';
import '../../l10n/app_localizations.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppConstants.homeRoute,
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoading = authProvider.isLoading;
      final isAuthRoute = [
        AppConstants.loginRoute,
        AppConstants.registerRoute,
        AppConstants.forgotPasswordRoute,
      ].contains(state.matchedLocation);

      // Don't redirect while loading
      if (isLoading) {
        return null;
      }

      // If authenticated and on auth route, redirect to home
      if (isAuthenticated && isAuthRoute) {
        return AppConstants.homeRoute;
      }

      // Allow guest access - no forced redirects to login
      return null;
    },
    routes: [
      // Authentication routes
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.registerRoute,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.forgotPasswordRoute,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main app routes with shell navigation (guest access allowed)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return BottomNavigationWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: AppConstants.homeRoute,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppConstants.exploreRoute,
            name: 'explore',
            builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return ExploreScreen(selectedCategory: category);
            },
          ),
          GoRoute(
            path: AppConstants.favoritesRoute,
            name: 'favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: AppConstants.profileRoute,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppConstants.accountInfoRoute,
            name: 'account-info',
            builder: (context, state) => const AccountInfoScreen(),
          ),
          GoRoute(
            path: AppConstants.privacySettingsRoute,
            name: 'privacy-settings',
            builder: (context, state) => const PrivacySettingsScreen(),
          ),
          GoRoute(
            path: AppConstants.languageSettingsRoute,
            name: 'language-settings',
            builder: (context, state) => const LanguageSettingsScreen(),
          ),
        ],
      ),

      // Movie details route (guest access allowed)
      GoRoute(
        path: '${AppConstants.movieDetailsRoute}/:id',
        name: 'movie-details',
        builder: (context, state) {
          final movieId = int.parse(state.pathParameters['id']!);
          return ChangeNotifierProvider(
            create: (context) =>
                MovieDetailsProvider(context.read<MovieRepository>(), movieId),
            child: MovieDetailsScreen(movieId: movieId),
          );
        },
      ),

      // All items route (guest access allowed)
      GoRoute(
        path: '${AppConstants.allItemsRoute}/:collectionType',
        name: 'all-items',
        builder: (context, state) {
          final collectionTypeString = state.pathParameters['collectionType']!;
          final collectionType = CollectionType.values.firstWhere(
            (type) => type.name == collectionTypeString,
            orElse: () => CollectionType.nowPlaying,
          );
          return AllItemsScreen(collectionType: collectionType);
        },
      ),
    ],
    errorBuilder: (context, state) {
      final localizations = AppLocalizations.of(context)!;
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                localizations.pageNotFound,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                localizations.pageNotFoundMessage,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppConstants.homeRoute),
                child: Text(localizations.goHome),
              ),
            ],
          ),
        ),
      );
    },
  );

  /// Navigate to movie details
  static void goToMovieDetails(BuildContext context, int movieId) {
    context.push('${AppConstants.movieDetailsRoute}/$movieId');
  }

  /// Navigate to home
  static void goToHome(BuildContext context) {
    context.go(AppConstants.homeRoute);
  }

  /// Navigate to explore
  static void goToExplore(BuildContext context) {
    context.go(AppConstants.exploreRoute);
  }

  /// Navigate to explore with selected category
  static void goToExploreWithCategory(BuildContext context, String category) {
    context.go(
      '${AppConstants.exploreRoute}?category=${Uri.encodeComponent(category)}',
    );
  }

  /// Navigate to favorites
  static void goToFavorites(BuildContext context) {
    context.go(AppConstants.favoritesRoute);
  }

  /// Navigate to profile
  static void goToProfile(BuildContext context) {
    context.go(AppConstants.profileRoute);
  }

  /// Navigate to login
  static void goToLogin(BuildContext context) {
    context.go(AppConstants.loginRoute);
  }

  /// Navigate to register
  static void goToRegister(BuildContext context) {
    context.go(AppConstants.registerRoute);
  }

  /// Navigate to forgot password
  static void goToForgotPassword(BuildContext context) {
    context.go(AppConstants.forgotPasswordRoute);
  }

  /// Navigate to all items screen
  static void goToAllItems(
    BuildContext context,
    CollectionType collectionType,
  ) {
    context.push('${AppConstants.allItemsRoute}/${collectionType.name}');
  }

  /// Get current route name
  static String? getCurrentRoute(BuildContext context) {
    final routeMatch = GoRouter.of(context).routerDelegate.currentConfiguration;
    return routeMatch.last.matchedLocation;
  }

  /// Check if current route is a tab route
  static bool isTabRoute(String route) {
    return [
      AppConstants.homeRoute,
      AppConstants.exploreRoute,
      AppConstants.favoritesRoute,
      AppConstants.profileRoute,
    ].contains(route);
  }

  /// Check if current route is an auth route
  static bool isAuthRoute(String route) {
    return [
      AppConstants.loginRoute,
      AppConstants.registerRoute,
      AppConstants.forgotPasswordRoute,
    ].contains(route);
  }
}

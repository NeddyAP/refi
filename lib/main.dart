import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/repositories/movie_repository.dart';
import 'features/home/providers/home_provider.dart';
import 'features/explore/providers/explore_provider.dart';
import 'features/favorites/providers/favorites_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'shared/providers/navigation_visibility_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize API client
  ApiClient().initialize();

  // Initialize authentication service
  await AuthService().initialize();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<MovieRepository>(
          create: (_) => MovieRepositoryImpl(ApiClient()),
        ),
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(AuthService()),
        ),

        // Providers
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (_) => FavoritesProvider(),
        ),
        ChangeNotifierProxyProvider<MovieRepository, HomeProvider>(
          create: (context) => HomeProvider(
            context.read<MovieRepository>(),
          ),
          update: (context, movieRepo, previous) => previous ?? HomeProvider(movieRepo),
        ),
        ChangeNotifierProxyProvider<MovieRepository, ExploreProvider>(
          create: (context) => ExploreProvider(
            context.read<MovieRepository>(),
          ),
          update: (context, movieRepo, previous) => previous ?? ExploreProvider(movieRepo),
        ),
        ChangeNotifierProvider<NavigationVisibilityProvider>(
          create: (_) => NavigationVisibilityProvider(),
        ),

      ],
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          return MaterialApp.router(
            title: 'Refi - Movie Recommendations',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: profileProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

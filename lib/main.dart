import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/update_service.dart';
import 'shared/repositories/movie_repository.dart';
import 'features/home/providers/home_provider.dart';
import 'features/explore/providers/explore_provider.dart';
import 'features/favorites/providers/favorites_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'shared/providers/navigation_visibility_provider.dart';
import 'shared/repositories/tmdb_account_repository.dart';
import 'features/auth/services/tmdb_auth_service.dart';
import 'shared/widgets/update_dialog.dart';

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
          create: (context) => AuthProvider(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider()..initialize(),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (_) => FavoritesProvider(
            TmdbAccountRepository(
              ApiClient(),
              () => TmdbAuthService().currentUser!,
            ),
          ),
        ),
        ChangeNotifierProxyProvider<MovieRepository, HomeProvider>(
          create: (context) => HomeProvider(context.read<MovieRepository>()),
          update: (context, movieRepo, previous) =>
              previous ?? HomeProvider(movieRepo),
        ),
        ChangeNotifierProxyProvider<MovieRepository, ExploreProvider>(
          create: (context) => ExploreProvider(context.read<MovieRepository>()),
          update: (context, movieRepo, previous) =>
              previous ?? ExploreProvider(movieRepo),
        ),
        ChangeNotifierProvider<NavigationVisibilityProvider>(
          create: (_) => NavigationVisibilityProvider(),
        ),
      ],
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          return UpdateWrapper(
            child: MaterialApp.router(
              onGenerateTitle: (BuildContext context) {
                // This context is safe to use for AppLocalizations
                return AppLocalizations.of(context)!.appTitleFull;
              },
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: profileProvider.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              locale: Locale(profileProvider.appLanguageCode),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('id')],
              routerConfig: AppRouter.router,
            ),
          );
        },
      ),
    );
  }
}

/// Wrapper widget that handles update checking functionality
class UpdateWrapper extends StatefulWidget {
  final Widget child;

  const UpdateWrapper({
    super.key,
    required this.child,
  });

  @override
  State<UpdateWrapper> createState() => _UpdateWrapperState();
}

class _UpdateWrapperState extends State<UpdateWrapper> {
  final UpdateService _updateService = UpdateService();
  bool _hasCheckedForUpdate = false;

  @override
  void initState() {
    super.initState();
    // Check for updates after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    // Only check once per app session
    if (_hasCheckedForUpdate) return;
    
    try {
      _hasCheckedForUpdate = true;
      final updateResult = await _updateService.isUpdateAvailable();
      
      if (updateResult.isAvailable &&
          updateResult.latestVersion != null &&
          updateResult.downloadUrl != null &&
          mounted) {
        
        // Show update dialog
        await UpdateDialog.show(
          context: context,
          latestVersion: updateResult.latestVersion!,
          downloadUrl: updateResult.downloadUrl!,
          updateService: _updateService,
        );
      }
    } catch (e) {
      // Silently handle update check errors
      // In production, you might want to log this error
      debugPrint('Update check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

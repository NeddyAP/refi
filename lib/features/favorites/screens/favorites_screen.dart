import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/widgets/movie_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Movies',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Favorites'),
            Tab(text: 'Watchlist'),
          ],
        ),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Loading your movies...');
          }
          if (provider.errorMessage != null) {
            return ErrorDisplayWidget(
              message: provider.errorMessage!,
              onRetry: provider.pullToRefresh,
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _FavoritesTab(provider: provider),
              _WatchlistTab(provider: provider),
            ],
          );
        },
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  final FavoritesProvider provider;

  const _FavoritesTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: provider.pullToRefresh,
      child: provider.favoriteMovies.isEmpty
          ? NoFavoritesWidget(onExplore: () => AppRouter.goToExplore(context))
          : GridView.builder(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).padding.bottom + 100,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: provider.favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = provider.favoriteMovies[index];
                return Stack(
                  children: [
                    MovieCard(
                      movie: movie,
                      onTap: () =>
                          AppRouter.goToMovieDetails(context, movie.id),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        tooltip: 'Remove from favorites',
                        onPressed: () => provider.removeFromFavorites(movie.id),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _WatchlistTab extends StatelessWidget {
  final FavoritesProvider provider;

  const _WatchlistTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: provider.pullToRefresh,
      child: provider.watchlistMovies.isEmpty
          ? const EmptyStateWidget(
              title: 'No Movies in Watchlist',
              message:
                  'Add movies to your watchlist to keep track of what you want to watch.',
              icon: Icons.playlist_add,
            )
          : GridView.builder(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).padding.bottom + 100,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: provider.watchlistMovies.length,
              itemBuilder: (context, index) {
                final movie = provider.watchlistMovies[index];
                return Stack(
                  children: [
                    MovieCard(
                      movie: movie,
                      onTap: () =>
                          AppRouter.goToMovieDetails(context, movie.id),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.bookmark_remove,
                          color: Colors.blueGrey,
                        ),
                        tooltip: 'Remove from watchlist',
                        onPressed: () => provider.removeFromWatchlist(movie.id),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refi/core/network/api_result.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/widgets/movie_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../providers/explore_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Explore',
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search movies...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ExploreProvider>().clearSearch();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                context.read<ExploreProvider>().searchMovies(value);
              },
            ),
          ),
          
          // Content
          Expanded(
            child: Consumer<ExploreProvider>(
              builder: (context, provider, child) {
                // Show search results if searching
                if (provider.searchQuery.isNotEmpty) {
                  return _SearchResults(provider: provider);
                }
                
                // Show genre selection and movies
                return _GenreExploration(provider: provider);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final ExploreProvider provider;

  const _SearchResults({required this.provider});

  @override
  Widget build(BuildContext context) {
    return provider.searchResults?.when(
      success: (movieResponse) {
        if (movieResponse.results.isEmpty) {
          return NoResultsWidget(
            searchQuery: provider.searchQuery,
            onClearSearch: () => provider.clearSearch(),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: movieResponse.results.length,
          itemBuilder: (context, index) {
            final movie = movieResponse.results[index];
            return MovieCard(
              movie: movie,
              onTap: () => AppRouter.goToMovieDetails(context, movie.id),
            );
          },
        );
      },
      error: (message, statusCode) => ErrorDisplayWidget(
        message: message,
        onRetry: () => provider.retrySearch(),
      ),
      loading: () => GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const MovieCardSkeleton();
        },
      ),
    ) ?? const SizedBox.shrink();
  }
}

class _GenreExploration extends StatelessWidget {
  final ExploreProvider provider;

  const _GenreExploration({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Genres section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Browse by Genre',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Genre chips
        SizedBox(
          height: 50,
          child: provider.genres?.when(
            success: (genreResponse) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: genreResponse.genres.length,
                itemBuilder: (context, index) {
                  final genre = genreResponse.genres[index];
                  final isSelected = provider.selectedGenre?.id == genre.id;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(genre.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          provider.selectGenre(genre);
                        } else {
                          provider.clearGenreSelection();
                        }
                      },
                    ),
                  );
                },
              );
            },
            error: (message, statusCode) => Center(
              child: Text('Failed to load genres: $message'),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ) ?? const SizedBox.shrink(),
        ),
        
        const SizedBox(height: 16),
        
        // Genre movies
        Expanded(
          child: provider.genreMovies?.when(
            success: (movieResponse) {
              if (movieResponse.results.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No Movies Found',
                  message: 'No movies found for this genre.',
                );
              }
              
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: movieResponse.results.length,
                itemBuilder: (context, index) {
                  final movie = movieResponse.results[index];
                  return MovieCard(
                    movie: movie,
                    onTap: () => AppRouter.goToMovieDetails(context, movie.id),
                  );
                },
              );
            },
            error: (message, statusCode) => ErrorDisplayWidget(
              message: message,
              onRetry: () => provider.retryGenreMovies(),
            ),
            loading: () => GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return const MovieCardSkeleton();
              },
            ),
          ) ?? const EmptyStateWidget(
            title: 'Select a Genre',
            message: 'Choose a genre above to discover movies.',
            icon: Icons.category,
          ),
        ),
      ],
    );
  }
}

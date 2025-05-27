import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:refi/core/network/api_result.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/widgets/movie_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/providers/navigation_visibility_provider.dart';
import '../providers/explore_provider.dart';

class ExploreScreen extends StatefulWidget {
  final String? selectedCategory;
  
  const ExploreScreen({super.key, this.selectedCategory});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ExploreProvider>();
      provider.initialize();
      
      // If a category is provided, search for it or select it
      if (widget.selectedCategory != null) {
        provider.searchMoviesByGenre(widget.selectedCategory!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAdvancedSearchModal(BuildContext context) {
    // Hide the bottom navigation bar when modal opens
    context.read<NavigationVisibilityProvider>().hide();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AdvancedSearchModal(),
    ).then((_) {
      // Show the bottom navigation bar when modal closes
      context.read<NavigationVisibilityProvider>().show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Explore',
      ),
      body: Consumer<ExploreProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Search bar with advanced search toggle
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        enabled: !provider.isAdvancedSearchMode,
                        decoration: InputDecoration(
                          hintText: provider.isAdvancedSearchMode
                              ? 'Advanced search active'
                              : 'Search movies...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty && !provider.isAdvancedSearchMode
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.clearSearch();
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          if (!provider.isAdvancedSearchMode) {
                            provider.searchMovies(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        if (provider.isAdvancedSearchMode) {
                          provider.toggleAdvancedSearchMode();
                          _searchController.clear();
                        } else {
                          _showAdvancedSearchModal(context);
                        }
                      },
                      icon: Icon(
                        provider.isAdvancedSearchMode
                            ? Icons.search_off
                            : Icons.tune,
                        color: provider.isAdvancedSearchMode
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      tooltip: provider.isAdvancedSearchMode
                          ? 'Exit advanced search'
                          : 'Advanced search',
                    ),
                  ],
                ),
              ),

              // Applied filters indicator
              if (provider.hasAdvancedFilters)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.appliedFiltersDescription,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => provider.clearAdvancedSearch(),
                        icon: Icon(
                          Icons.clear,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

              if (provider.hasAdvancedFilters)
                const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: _buildContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(ExploreProvider provider) {
    // Show advanced search results
    if (provider.isAdvancedSearchMode && provider.hasAdvancedFilters) {
      return _AdvancedSearchResults(provider: provider);
    }
    
    // Show search results if searching
    if (provider.searchQuery.isNotEmpty) {
      return _SearchResults(provider: provider);
    }
    
    // Show default/popular movies when no search or filters are active
    return _DefaultMoviesDisplay(provider: provider);
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
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).padding.bottom + 100
          ),
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

class _AdvancedSearchResults extends StatelessWidget {
  final ExploreProvider provider;

  const _AdvancedSearchResults({required this.provider});

  @override
  Widget build(BuildContext context) {
    return provider.advancedSearchResults?.when(
      success: (movieResponse) {
        if (movieResponse.results.isEmpty) {
          return NoResultsWidget(
            searchQuery: 'advanced search',
            onClearSearch: () => provider.clearAdvancedSearch(),
          );
        }
        
        return GridView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).padding.bottom + 100
          ),
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
        onRetry: () => provider.retryAdvancedSearch(),
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
      title: 'No Advanced Search Performed',
      message: 'Configure your filters and search for movies.',
      icon: Icons.tune,
    );
  }
}

class _AdvancedSearchModal extends StatefulWidget {
  const _AdvancedSearchModal();

  @override
  State<_AdvancedSearchModal> createState() => _AdvancedSearchModalState();
}

class _AdvancedSearchModalState extends State<_AdvancedSearchModal> {
  // Language options for dropdown
  static const List<Map<String, String>> _languageOptions = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
    {'code': 'it', 'name': 'Italian'},
    {'code': 'ja', 'name': 'Japanese'},
    {'code': 'ko', 'name': 'Korean'},
    {'code': 'zh', 'name': 'Chinese'},
    {'code': 'pt', 'name': 'Portuguese'},
    {'code': 'ru', 'name': 'Russian'},
  ];

  // Sort options for dropdown
  static const List<Map<String, String>> _sortOptions = [
    {'value': 'popularity.desc', 'name': 'Popularity (High to Low)'},
    {'value': 'popularity.asc', 'name': 'Popularity (Low to High)'},
    {'value': 'release_date.desc', 'name': 'Release Date (Newest)'},
    {'value': 'release_date.asc', 'name': 'Release Date (Oldest)'},
    {'value': 'vote_average.desc', 'name': 'Rating (High to Low)'},
    {'value': 'vote_average.asc', 'name': 'Rating (Low to High)'},
    {'value': 'vote_count.desc', 'name': 'Vote Count (High to Low)'},
    {'value': 'revenue.desc', 'name': 'Revenue (High to Low)'},
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Advanced Search',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Scrollable content
              Expanded(
                child: Consumer<ExploreProvider>(
                  builder: (context, provider, child) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGenreSelection(context, provider),
                          const SizedBox(height: 24),
                          _buildReleaseYearSection(context, provider),
                          const SizedBox(height: 24),
                          _buildRatingSection(context, provider),
                          const SizedBox(height: 24),
                          _buildVoteCountSection(context, provider),
                          const SizedBox(height: 24),
                          _buildLanguageSection(context, provider),
                          const SizedBox(height: 24),
                          _buildRuntimeSection(context, provider),
                          const SizedBox(height: 24),
                          _buildSortSection(context, provider),
                          const SizedBox(height: 32),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Consumer<ExploreProvider>(
                  builder: (context, provider, child) {
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              provider.clearAdvancedSearch();
                            },
                            child: const Text('Clear Filters'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              provider.toggleAdvancedSearchMode();
                              provider.performAdvancedSearch();
                              Navigator.pop(context);
                            },
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenreSelection(BuildContext context, ExploreProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        provider.genres?.when(
          success: (genreResponse) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: genreResponse.genres.map((genre) {
                final isSelected = provider.selectedGenreIds.contains(genre.id);
                return FilterChip(
                  label: Text(genre.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newGenres = List<int>.from(provider.selectedGenreIds);
                    if (selected) {
                      newGenres.add(genre.id);
                    } else {
                      newGenres.remove(genre.id);
                    }
                    provider.updateSelectedGenres(newGenres);
                  },
                );
              }).toList(),
            );
          },
          error: (message, statusCode) => Text(
            'Failed to load genres: $message',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          loading: () => const CircularProgressIndicator(),
        ) ?? const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildReleaseYearSection(BuildContext context, ExploreProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Release Year',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'From Year',
                  hintText: '1900',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: (value) {
                  final year = int.tryParse(value);
                  provider.updateReleaseYearRange(year, provider.releaseYearEnd);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'To Year',
                  hintText: '2024',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: (value) {
                  final year = int.tryParse(value);
                  provider.updateReleaseYearRange(provider.releaseYearStart, year);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context, ExploreProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating Range',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: RangeValues(
            provider.ratingMin ?? 0.0,
            provider.ratingMax ?? 10.0,
          ),
          min: 0.0,
          max: 10.0,
          divisions: 100,
          labels: RangeLabels(
            (provider.ratingMin ?? 0.0).toStringAsFixed(1),
            (provider.ratingMax ?? 10.0).toStringAsFixed(1),
          ),
          onChanged: (values) {
            provider.updateRatingRange(values.start, values.end);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Min: ${(provider.ratingMin ?? 0.0).toStringAsFixed(1)}'),
            Text('Max: ${(provider.ratingMax ?? 10.0).toStringAsFixed(1)}'),
          ],
        ),
      ],
    );
  }

  Widget _buildVoteCountSection(BuildContext context, ExploreProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Vote Count',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Slider(
          value: (provider.minVoteCount ?? 0).toDouble(),
          min: 0,
          max: 5000,
          divisions: 100,
          label: '${provider.minVoteCount ?? 0}',
          onChanged: (value) {
            provider.updateMinVoteCount(value.toInt());
          },
        ),
        Text('Minimum votes: ${provider.minVoteCount ?? 0}'),
      ],
    );
  }

  Widget _buildLanguageSection(BuildContext context, ExploreProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Original Language',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: provider.selectedLanguage,
          decoration: const InputDecoration(
            labelText: 'Select Language',
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Any Language'),
            ),
            ..._languageOptions.map((lang) => DropdownMenuItem<String>(
              value: lang['code'],
              child: Text(lang['name']!),
            )),
          ],
          onChanged: (value) {
            provider.updateSelectedLanguage(value);
          },
        ),
      ],
    );
  }

  Widget _buildRuntimeSection(BuildContext context, ExploreProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Runtime (minutes)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Min Runtime',
                  hintText: '60',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  final runtime = int.tryParse(value);
                  provider.updateRuntimeRange(runtime, provider.runtimeMax);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Max Runtime',
                  hintText: '180',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  final runtime = int.tryParse(value);
                  provider.updateRuntimeRange(provider.runtimeMin, runtime);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortSection(BuildContext context, ExploreProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: provider.sortBy,
          decoration: const InputDecoration(
            labelText: 'Sort Order',
          ),
          items: _sortOptions.map((sort) => DropdownMenuItem<String>(
            value: sort['value'],
            child: Text(sort['name']!),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              provider.updateSortBy(value);
            }
          },
        ),
      ],
    );
  }
}

class _DefaultMoviesDisplay extends StatelessWidget {
  final ExploreProvider provider;

  const _DefaultMoviesDisplay({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Popular Movies',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Default movies grid
        Expanded(
          child: provider.defaultMovies?.when(
            success: (movieResponse) {
              if (movieResponse.results.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No Movies Available',
                  message: 'Unable to load popular movies at this time.',
                  icon: Icons.movie_outlined,
                );
              }
              
              return GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  MediaQuery.of(context).padding.bottom + 20
                ),
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
              onRetry: () => provider.retryDefaultMovies(),
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
            title: 'Loading...',
            message: 'Fetching popular movies for you.',
            icon: Icons.movie_outlined,
          ),
        ),
      ],
    );
  }
}

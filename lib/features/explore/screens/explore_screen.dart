import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
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
  final String? searchQuery;
  
  const ExploreScreen({super.key, this.selectedCategory, this.searchQuery});

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
      
      // If a search query is provided, perform the search
      if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
        _searchController.text = widget.searchQuery!;
        provider.searchMovies(widget.searchQuery!);
      }
      // If a category is provided, search for it or select it
      else if (widget.selectedCategory != null) {
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
      if (context.mounted) {
        context.read<NavigationVisibilityProvider>().show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.exploreScreenTitle,
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
                              ? AppLocalizations.of(context)!.advancedSearchActive
                              : AppLocalizations.of(context)!.searchMoviesHint,
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
                          ? AppLocalizations.of(context)!.exitAdvancedSearch
                          : AppLocalizations.of(context)!.advancedSearch,
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
            searchQuery: AppLocalizations.of(context)!.advancedSearch,
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
    ) ?? EmptyStateWidget(
      title: AppLocalizations.of(context)!.noAdvancedSearchPerformed,
      message: AppLocalizations.of(context)!.configureFiltersMessage,
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
  List<Map<String, String>> _getLanguageOptions(BuildContext context) => [
    {'code': 'en', 'name': AppLocalizations.of(context)!.english},
    {'code': 'es', 'name': AppLocalizations.of(context)!.spanish},
    {'code': 'fr', 'name': AppLocalizations.of(context)!.french},
    {'code': 'de', 'name': AppLocalizations.of(context)!.german},
    {'code': 'it', 'name': AppLocalizations.of(context)!.italian},
    {'code': 'ja', 'name': AppLocalizations.of(context)!.japanese},
    {'code': 'ko', 'name': AppLocalizations.of(context)!.korean},
    {'code': 'zh', 'name': AppLocalizations.of(context)!.chinese},
    {'code': 'pt', 'name': AppLocalizations.of(context)!.portuguese},
    {'code': 'ru', 'name': AppLocalizations.of(context)!.russian},
  ];

  // Sort options for dropdown
  List<Map<String, String>> _getSortOptions(BuildContext context) => [
    {'value': 'popularity.desc', 'name': AppLocalizations.of(context)!.popularityHighToLow},
    {'value': 'popularity.asc', 'name': AppLocalizations.of(context)!.popularityLowToHigh},
    {'value': 'release_date.desc', 'name': AppLocalizations.of(context)!.releaseDateNewest},
    {'value': 'release_date.asc', 'name': AppLocalizations.of(context)!.releaseDateOldest},
    {'value': 'vote_average.desc', 'name': AppLocalizations.of(context)!.ratingHighToLow},
    {'value': 'vote_average.asc', 'name': AppLocalizations.of(context)!.ratingLowToHigh},
    {'value': 'vote_count.desc', 'name': AppLocalizations.of(context)!.voteCountHighToLow},
    {'value': 'revenue.desc', 'name': AppLocalizations.of(context)!.revenueHighToLow},
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
                      AppLocalizations.of(context)!.advancedSearchTitle,
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
                      color: Theme.of(context).shadowColor.withAlpha((255 * 0.1).toInt()), // Replaced withOpacity
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
                            child: Text(AppLocalizations.of(context)!.clearFilters),
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
                            child: Text(AppLocalizations.of(context)!.applyFilters),
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
          AppLocalizations.of(context)!.genres,
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
            AppLocalizations.of(context)!.failedToLoadGenres(message),
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
          AppLocalizations.of(context)!.releaseYear,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.fromYear,
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.toYear,
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
          AppLocalizations.of(context)!.ratingRange,
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
            Text(AppLocalizations.of(context)!.minRatingLabel((provider.ratingMin ?? 0.0).toStringAsFixed(1))),
            Text(AppLocalizations.of(context)!.maxRatingLabel((provider.ratingMax ?? 10.0).toStringAsFixed(1))),
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
          AppLocalizations.of(context)!.minimumVoteCount,
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
        Text(AppLocalizations.of(context)!.minimumVotesLabel(provider.minVoteCount ?? 0)),
      ],
    );
  }

  Widget _buildLanguageSection(BuildContext context, ExploreProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.originalLanguage,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: provider.selectedLanguage,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.selectLanguage,
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(AppLocalizations.of(context)!.anyLanguage),
            ),
            ..._getLanguageOptions(context).map((lang) => DropdownMenuItem<String>(
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
          AppLocalizations.of(context)!.runtimeMinutes,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.minRuntime,
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.maxRuntime,
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
          AppLocalizations.of(context)!.sortBy,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: provider.sortBy,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.sortOrder,
          ),
          items: _getSortOptions(context).map((sort) => DropdownMenuItem<String>(
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
            AppLocalizations.of(context)!.popularMovies,
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
                return EmptyStateWidget(
                  title: AppLocalizations.of(context)!.noMoviesAvailable,
                  message: AppLocalizations.of(context)!.unableToLoadPopularMovies,
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
          ) ?? EmptyStateWidget(
            title: AppLocalizations.of(context)!.loadingText,
            message: AppLocalizations.of(context)!.fetchingPopularMovies,
            icon: Icons.movie_outlined,
          ),
        ),
      ],
    );
  }
}

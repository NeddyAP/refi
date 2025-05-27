import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/models/movie.dart';
import '../../../shared/models/tv_show.dart';
import '../../../shared/models/mixed_content.dart';
import '../providers/home_provider.dart';

/// Enum to identify different collection types
enum CollectionType {
  nowPlaying,
  topRated,
  trendingToday,
  trendingThisWeek,
  latestTrailers,
  popularOnStreaming,
  popularOnTv,
  availableForRent,
  currentlyInTheaters,
}

/// Extension to get display titles for collection types
extension CollectionTypeExtension on CollectionType {
  String get displayTitle {
    switch (this) {
      case CollectionType.nowPlaying:
        return 'Frequently Visited';
      case CollectionType.topRated:
        return 'Recommendations';
      case CollectionType.trendingToday:
        return 'Trending Today';
      case CollectionType.trendingThisWeek:
        return 'Trending This Week';
      case CollectionType.latestTrailers:
        return 'Latest Trailers';
      case CollectionType.popularOnStreaming:
        return 'Popular on Streaming';
      case CollectionType.popularOnTv:
        return 'Popular On TV';
      case CollectionType.availableForRent:
        return 'Available For Rent';
      case CollectionType.currentlyInTheaters:
        return 'Currently In Theaters';
    }
  }

  String get sectionKey {
    switch (this) {
      case CollectionType.nowPlaying:
        return 'nowPlaying';
      case CollectionType.topRated:
        return 'topRated';
      case CollectionType.trendingToday:
        return 'trendingToday';
      case CollectionType.trendingThisWeek:
        return 'trendingThisWeek';
      case CollectionType.latestTrailers:
        return 'latestTrailers';
      case CollectionType.popularOnStreaming:
        return 'popularOnStreaming';
      case CollectionType.popularOnTv:
        return 'popularOnTv';
      case CollectionType.availableForRent:
        return 'availableForRent';
      case CollectionType.currentlyInTheaters:
        return 'currentlyInTheaters';
    }
  }
}

/// Screen to display all items from a specific collection
class AllItemsScreen extends StatelessWidget {
  final CollectionType collectionType;

  const AllItemsScreen({
    super.key,
    required this.collectionType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(collectionType.displayTitle),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          final apiResult = _getApiResultForCollection(provider, collectionType);
          
          return apiResult?.when(
            success: (response) => _buildSuccessContent(context, response),
            error: (message, statusCode) => _buildErrorContent(context, message, provider),
            loading: () => _buildLoadingContent(),
          ) ?? _buildLoadingContent();
        },
      ),
    );
  }

  /// Get the appropriate API result for the collection type
  ApiResult<dynamic>? _getApiResultForCollection(HomeProvider provider, CollectionType type) {
    switch (type) {
      case CollectionType.nowPlaying:
        return provider.nowPlayingMovies;
      case CollectionType.topRated:
        return provider.topRatedMovies;
      case CollectionType.trendingToday:
        return provider.trendingToday;
      case CollectionType.trendingThisWeek:
        return provider.trendingThisWeek;
      case CollectionType.latestTrailers:
        return provider.latestTrailers;
      case CollectionType.popularOnStreaming:
        return provider.popularOnStreaming;
      case CollectionType.popularOnTv:
        return provider.popularOnTv;
      case CollectionType.availableForRent:
        return provider.availableForRent;
      case CollectionType.currentlyInTheaters:
        return provider.currentlyInTheaters;
    }
  }

  Widget _buildSuccessContent(BuildContext context, dynamic response) {
    List<dynamic> items = [];
    
    // Handle different response types
    if (response is MovieResponse) {
      items = response.results;
    } else if (response is TvShowResponse) {
      items = response.results;
    } else if (response is MixedContentResponse) {
      items = response.results;
    }

    if (items.isEmpty) {
      return const Center(
        child: Text('No content available'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ItemGridCard(
          item: item,
          onTap: () => _handleItemTap(context, item),
        );
      },
    );
  }

  Widget _buildErrorContent(BuildContext context, String message, HomeProvider provider) {
    return Center(
      child: ErrorDisplayWidget(
        message: message,
        onRetry: () => provider.retrySection(collectionType.sectionKey),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return const MovieCardSkeleton();
      },
    );
  }

  void _handleItemTap(BuildContext context, dynamic item) {
    // For now, navigate to movie details for all items
    // This could be enhanced to handle TV shows differently in the future
    if (item is MixedContentItem && item.mediaType == MediaType.tv) {
      // For TV shows, we could navigate to a TV show details screen
      // For now, we'll navigate to movie details with the TV show's movie conversion
      final movie = item.toMovie();
      if (movie != null) {
        AppRouter.goToMovieDetails(context, movie.id);
      }
    } else if (item is Movie) {
      AppRouter.goToMovieDetails(context, item.id);
    } else if (item is TvShow) {
      // For TV shows, navigate to movie details for now (could be enhanced later)
      AppRouter.goToMovieDetails(context, item.id);
    } else if (item is MixedContentItem) {
      AppRouter.goToMovieDetails(context, item.id);
    }
  }
}

/// Grid card widget for displaying items in the AllItemsScreen
class _ItemGridCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onTap;

  const _ItemGridCard({
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content Poster
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _getPosterUrl() != null
                        ? Image.network(
                            _getPosterUrl()!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(context),
                          )
                        : _buildPlaceholderImage(context),
                  ),
                ),
                // Bookmark Icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                // Rating Badge
                if (_getVoteAverage() > 0)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade400,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _getVoteAverage().toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Content Title
          Text(
            _getTitle(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Media Type or Genre
          Text(
            _getSubtitle(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.movie,
        size: 50,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }

  String? _getPosterUrl() {
    if (item is Movie) {
      return (item as Movie).fullPosterUrl;
    } else if (item is TvShow) {
      return (item as TvShow).fullPosterUrl;
    } else if (item is MixedContentItem) {
      return (item as MixedContentItem).fullPosterUrl;
    }
    return null;
  }

  double _getVoteAverage() {
    if (item is Movie) {
      return (item as Movie).voteAverage;
    } else if (item is TvShow) {
      return (item as TvShow).voteAverage;
    } else if (item is MixedContentItem) {
      return (item as MixedContentItem).voteAverage;
    }
    return 0.0;
  }

  String _getTitle() {
    if (item is Movie) {
      return (item as Movie).title;
    } else if (item is TvShow) {
      return (item as TvShow).name;
    } else if (item is MixedContentItem) {
      return (item as MixedContentItem).title;
    }
    return 'Unknown';
  }

  String _getSubtitle() {
    if (item is MixedContentItem) {
      final mixedItem = item as MixedContentItem;
      return mixedItem.mediaTypeString;
    } else if (item is TvShow) {
      return 'TV Show';
    } else {
      return 'Movie';
    }
  }
}
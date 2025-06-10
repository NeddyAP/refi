import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/models/movie.dart';
import '../../../shared/models/tv_show.dart';
import '../../../shared/models/mixed_content.dart';
import '../screens/all_items_screen.dart';

/// Base class for content items that can be displayed in the carousel
abstract class CarouselContentItem {
  int get id;
  String get title;
  String? get posterPath;
  double get voteAverage;
  String? get fullPosterUrl;
  String get mediaTypeString;
}

/// Extension to make Movie compatible with CarouselContentItem
extension MovieCarouselItem on Movie {
  String get mediaTypeString => 'Movie';
}

/// Extension to make TvShow compatible with CarouselContentItem
extension TvShowCarouselItem on TvShow {
  String get mediaTypeString => 'TV Show';
}

/// Extension to make MixedContentItem compatible with CarouselContentItem
extension MixedContentCarouselItem on MixedContentItem {
  // MixedContentItem already has mediaTypeString getter
}

/// A reusable horizontal scrollable content carousel widget
class ContentCarousel extends StatelessWidget {
  final String title;
  final ApiResult<dynamic>? apiResult;
  final String sectionKey;
  final VoidCallback onRetry;
  final EdgeInsets padding;
  final CollectionType? collectionType;

  const ContentCarousel({
    super.key,
    required this.title,
    required this.apiResult,
    required this.sectionKey,
    required this.onRetry,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.collectionType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (collectionType != null)
                GestureDetector(
                  onTap: () => AppRouter.goToAllItems(context, collectionType!),
                  child: Text(
                    'View More',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return apiResult?.when(
      success: (response) => _buildSuccessContent(context, response),
      error: (message, statusCode) => _buildErrorContent(context, message),
      loading: () => _buildLoadingContent(),
    ) ?? _buildLoadingContent();
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
      return const Center(child: Text('No content available'));
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: padding,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _ContentCard(
            item: item,
            onTap: () => _handleItemTap(context, item),
          ),
        );
      },
    );
  }

  Widget _buildErrorContent(BuildContext context, String message) {
    return Center(
      child: ErrorDisplayWidget(
        message: message,
        onRetry: onRetry,
      ),
    );
  }

  Widget _buildLoadingContent() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: padding,
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(right: 12),
          child: MovieCardSkeleton(),
        );
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

/// Individual content card widget
class _ContentCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onTap;

  const _ContentCard({
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: GestureDetector(
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
                          color: Colors.black.withAlpha((255 * 0.1).toInt()), // Replaced withOpacity
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
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((255 * 0.9).toInt()), // Replaced withOpacity
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((255 * 0.1).toInt()), // Replaced withOpacity
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bookmark_border,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // Rating Badge
                  if (_getVoteAverage() > 0)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade400,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withAlpha((255 * 0.3).toInt()), // Replaced withOpacity
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
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _getVoteAverage().toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
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
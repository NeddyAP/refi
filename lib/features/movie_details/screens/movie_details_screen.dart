import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:refi/core/network/api_result.dart';
import 'youtube_player_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/models/movie.dart';
import '../../../shared/models/movie_video.dart';
import '../../../shared/models/movie_cast.dart';
import '../../../shared/models/movie_review.dart';
import '../../../shared/models/movie_images.dart';
import '../../../shared/providers/navigation_visibility_provider.dart';
import '../../../features/favorites/providers/favorites_provider.dart';
import '../providers/movie_details_provider.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  NavigationVisibilityProvider? _navigationProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Store reference to NavigationVisibilityProvider
      _navigationProvider = Provider.of<NavigationVisibilityProvider>(
        context,
        listen: false,
      );
      // Hide bottom navigation bar when movie details screen is shown
      _navigationProvider?.hide();
      context.read<MovieDetailsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    // Show bottom navigation bar when movie details screen is disposed
    // Use stored reference instead of accessing via context
    // Defer the update to prevent FlutterError when widget tree is locked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationProvider?.show();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use Scaffold without explicit backgroundColor to inherit theme background
    return Scaffold(
      // ...existing body...
      body: Consumer<MovieDetailsProvider>(
        builder: (context, provider, child) {
          return provider.movieDetails?.when(
                success: (movieDetails) =>
                    _MovieDetailsContent(movieDetails: movieDetails),
                error: (message, statusCode) => Scaffold(
                  appBar: AppBar(),
                  body: ErrorDisplayWidget(
                    message: message,
                    onRetry: () => provider.retry(),
                  ),
                ),
                loading: () => Scaffold(
                  body: LoadingWidget(message: AppLocalizations.of(context)!.loadingMovieDetails),
                ),
              ) ??
              Scaffold(
                body: LoadingWidget(message: AppLocalizations.of(context)!.loadingMovieDetails),
              );
        },
      ),
    );
  }
}

class _MovieDetailsContent extends StatelessWidget {
  final dynamic movieDetails;

  const _MovieDetailsContent({required this.movieDetails});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main scrollable content
        CustomScrollView(
          slivers: [
            // Top section with background image
            SliverToBoxAdapter(child: _TopSection(movieDetails: movieDetails)),
            // Main content with curved separation
            SliverToBoxAdapter(child: _MainContent(movieDetails: movieDetails)),
          ],
        ),

        // Header overlay
        Positioned(top: 0, left: 0, right: 0, child: _HeaderSection()),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context); // Unused local variable
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withAlpha((255 * 0.3).toInt()), // Replaced withOpacity
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            // Favorite and Bookmark icons
            Consumer<FavoritesProvider>(
              builder: (context, favoritesProvider, child) {
                final movieDetails =
                    (context
                                .findAncestorWidgetOfExactType<
                                  _MovieDetailsContent
                                >())
                        ?.movieDetails; // Removed unnecessary cast
                if (movieDetails == null) return const SizedBox.shrink();
                final movie = Movie(
                  id: movieDetails.id,
                  title: movieDetails.title,
                  overview: movieDetails.overview,
                  posterPath: movieDetails.posterPath,
                  backdropPath: movieDetails.backdropPath,
                  releaseDate: movieDetails.releaseDate,
                  voteAverage: movieDetails.voteAverage,
                  voteCount: movieDetails.voteCount,
                  genreIds: movieDetails.genres
                      .map<int>((g) => g.id as int)
                      .toList(),
                  adult: movieDetails.adult,
                  originalLanguage: movieDetails.originalLanguage,
                  originalTitle: movieDetails.originalTitle,
                  popularity: movieDetails.popularity,
                  video: movieDetails.video,
                );
                final isFavorite = favoritesProvider.isFavorite(movie.id);
                final isInWatchlist = favoritesProvider.isInWatchlist(movie.id);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final localizations = AppLocalizations.of(context)!;
                        await favoritesProvider.toggleFavorite(movie);
                        final msg = favoritesProvider.errorMessage == null
                            ? (favoritesProvider.isFavorite(movie.id)
                                  ? localizations.addedToFavorites
                                  : localizations.removedFromFavorites)
                            : favoritesProvider.errorMessage!;
                        if (!context.mounted) return; // Check if context is still valid
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(msg)));
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        size: 28,
                      ),
                      tooltip: isFavorite
                          ? AppLocalizations.of(context)!.removeFromFavorites
                          : AppLocalizations.of(context)!.addToFavorites,
                    ),
                    IconButton(
                      onPressed: () async {
                        final localizations = AppLocalizations.of(context)!;
                        await favoritesProvider.toggleWatchlist(movie);
                        final msg = favoritesProvider.errorMessage == null
                            ? (favoritesProvider.isInWatchlist(movie.id)
                                  ? localizations.addedToWatchlist
                                  : localizations.removedFromWatchlist)
                            : favoritesProvider.errorMessage!;
                        if (!context.mounted) return; // Check if context is still valid
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(msg)));
                      },
                      icon: Icon(
                        isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white,
                        size: 28,
                      ),
                      tooltip: isInWatchlist
                          ? AppLocalizations.of(context)!.removeFromWatchlist
                          : AppLocalizations.of(context)!.addToWatchlist,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TopSection extends StatelessWidget {
  final dynamic movieDetails;

  const _TopSection({required this.movieDetails});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: movieDetails.fullBackdropUrl != null
                ? CachedNetworkImage(
                    imageUrl: movieDetails.fullBackdropUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.movie,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.movie,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),

          // Dark overlay (keep as is, it's meant to darken the background image)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha((255 * 0.3).toInt()), // Replaced withOpacity
                    Colors.black.withAlpha((255 * 0.7).toInt()), // Replaced withOpacity
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final dynamic movieDetails;

  const _MainContent({required this.movieDetails});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      // Use theme surface color for the main content background
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie title and bookmark
            _MovieTitleSection(movieDetails: movieDetails),

            const SizedBox(height: 24),

            // Movie info (runtime, release year, rating)
            _MovieInfoSection(movieDetails: movieDetails),

            const SizedBox(height: 24),

            // Description section
            _DescriptionSection(movieDetails: movieDetails),

            const SizedBox(height: 32),

            // Trailers section
            _TrailersSection(),

            const SizedBox(height: 32),

            // Top billed cast section
            _TopBilledCastSection(),

            const SizedBox(height: 32),

            // Full cast & crew section
            _FullCastCrewSection(),

            const SizedBox(height: 32),

            // Reviews section
            _ReviewsSection(),

            const SizedBox(height: 32),

            // Image galleries section
            _ImageGalleriesSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _MovieTitleSection extends StatelessWidget {
  final dynamic movieDetails;

  const _MovieTitleSection({required this.movieDetails});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.1).toInt()), // Replaced withOpacity
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: movieDetails.fullPosterUrl != null
                ? CachedNetworkImage(
                    imageUrl: movieDetails.fullPosterUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.movie,
                        size: 24,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.movie,
                        size: 24,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.movie,
                      size: 24,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movieDetails.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  // Use onSurface color for text
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              // Genres as chips
              if (movieDetails.genres.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: movieDetails.genres.take(3).map<Widget>((genre) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        // Use a theme-aware background for chips
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        genre.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          // Use onSurfaceVariant for chip text
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 8),

              // Rating display
              Row(
                children: [
                  Text(
                    movieDetails.formattedRating,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      // Use onSurface color for rating text
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < (movieDetails.voteAverage / 2).round()
                            ? Icons.star
                            : Icons.star_border,
                        // Keep amber for stars
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MovieInfoSection extends StatelessWidget {
  final dynamic movieDetails;

  const _MovieInfoSection({required this.movieDetails});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (movieDetails.formattedRuntime != null) ...[
          _InfoChip(
            icon: Icons.access_time,
            label: movieDetails.formattedRuntime!,
          ),
          const SizedBox(width: 12),
        ],
        if (movieDetails.releaseYear != null) ...[
          _InfoChip(
            icon: Icons.calendar_today,
            label: movieDetails.releaseYear!,
          ),
          const SizedBox(width: 12),
        ],
        _InfoChip(
          icon: Icons.star,
          label: '${movieDetails.formattedRating}/10',
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // Use a theme-aware background for chips
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use onSurfaceVariant for icon
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              // Use onSurfaceVariant for text
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final dynamic movieDetails;

  const _DescriptionSection({required this.movieDetails});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.overview,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            // Use onSurface color for title
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 12),

        if (movieDetails.overview != null && movieDetails.overview!.isNotEmpty)
          Text(
            movieDetails.overview!,
            style: theme.textTheme.bodyMedium?.copyWith(
              // Use onSurface color for overview text
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          )
        else
          Text(
            AppLocalizations.of(context)!.noOverviewAvailable,
            style: theme.textTheme.bodyMedium?.copyWith(
              // Use onSurfaceVariant for placeholder text
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}

class _TrailersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<MovieDetailsProvider>(
      builder: (context, provider, child) {
        final trailers = provider.trailers;

        if (trailers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.trailers,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                // Use onSurface color for title
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: trailers.length,
                itemBuilder: (context, index) {
                  final trailer = trailers[index];
                  return _TrailerCard(trailer: trailer);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TrailerCard extends StatelessWidget {
  final MovieVideo trailer;

  const _TrailerCard({required this.trailer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          final videoId = trailer.key;
          if (videoId.isNotEmpty) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => YouTubePlayerScreen(
                  videoId: videoId,
                  videoTitle: trailer.name,
                ),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play button
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((255 * 0.1).toInt()), // Replaced withOpacity
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: trailer.youtubeThumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: trailer.youtubeThumbnailUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.video_library,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.video_library,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),

                  // Play button overlay (keep as is, white icon on dark overlay)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((255 * 0.3).toInt()), // Replaced withOpacity
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Trailer title
            Text(
              trailer.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                // Use onSurface color for title
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Trailer type
            Text(
              trailer.type,
              style: theme.textTheme.bodySmall?.copyWith(
                // Use onSurfaceVariant for type
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBilledCastSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<MovieDetailsProvider>(
      builder: (context, provider, child) {
        final cast = provider.topBilledCast;

        if (cast.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.topBilledCast,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                // Use onSurface color for title
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cast.length,
                itemBuilder: (context, index) {
                  final castMember = cast[index];
                  return _CastMemberCard(castMember: castMember);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CastMemberCard extends StatelessWidget {
  final CastMember castMember;

  const _CastMemberCard({required this.castMember});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.1).toInt()), // Replaced withOpacity
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: castMember.fullProfileUrl != null
                  ? CachedNetworkImage(
                      imageUrl: castMember.fullProfileUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 8),

          // Actor name
          Text(
            castMember.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              // Use onSurface color for name
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Character name
          Text(
            castMember.character,
            style: theme.textTheme.bodySmall?.copyWith(
              // Use onSurfaceVariant for character
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FullCastCrewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<MovieDetailsProvider>(
      builder: (context, provider, child) {
        return provider.movieCredits?.when(
              success: (credits) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.fullCastAndCrew,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      // Use onSurface color for title
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Director info
                  if (credits.director != null) ...[
                    _CrewMemberRow(
                      title: AppLocalizations.of(context)!.director,
                      crewMember: credits.director!,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Writers
                  if (credits.writers.isNotEmpty) ...[
                    _CrewMemberRow(
                      title: AppLocalizations.of(context)!.writers,
                      crewMember: credits.writers.first,
                      additionalCount: credits.writers.length - 1,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // View full cast button
                  TextButton(
                    onPressed: () {
                      _showFullCastBottomSheet(context, credits);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.viewFullCastAndCrew,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        // Use primary color for button text
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              error: (message, statusCode) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
            ) ??
            const SizedBox.shrink();
      },
    );
  }

  void _showFullCastBottomSheet(BuildContext context, dynamic credits) {
    // Navigation bar is already hidden in movie details screen, no need to hide again
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Use theme background for the modal
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => _FullCastBottomSheet(
          credits: credits,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _CrewMemberRow extends StatelessWidget {
  final String title;
  final CrewMember crewMember;
  final int additionalCount;

  const _CrewMemberRow({
    required this.title,
    required this.crewMember,
    this.additionalCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              // Use onSurface color for title
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: Text(
            additionalCount > 0
                ? '${crewMember.name} (+$additionalCount more)'
                : crewMember.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              // Use onSurfaceVariant for name
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _FullCastBottomSheet extends StatelessWidget {
  final dynamic credits;
  final ScrollController scrollController;

  const _FullCastBottomSheet({
    required this.credits,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // Use theme surface color for background
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              // Use theme surfaceContainer color for handle
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppLocalizations.of(context)!.fullCastAndCrew,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                // Use onSurface color for header
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Cast section
                Text(
                  AppLocalizations.of(context)!.cast,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    // Use onSurface color for section title
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ...credits.cast.map<Widget>(
                  (castMember) => _FullCastMemberTile(castMember: castMember),
                ),

                const SizedBox(height: 24),

                // Crew section
                Text(
                  AppLocalizations.of(context)!.crew,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    // Use onSurface color for section title
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ...credits.crew.map<Widget>(
                  (crewMember) => _FullCrewMemberTile(crewMember: crewMember),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FullCastMemberTile extends StatelessWidget {
  final CastMember castMember;

  const _FullCastMemberTile({required this.castMember});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Profile image
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 50,
              height: 60,
              child: castMember.fullProfileUrl != null
                  ? CachedNetworkImage(
                      imageUrl: castMember.fullProfileUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Name and character
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  castMember.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    // Use onSurface color for name
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  castMember.character,
                  style: theme.textTheme.bodySmall?.copyWith(
                    // Use onSurfaceVariant for character
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FullCrewMemberTile extends StatelessWidget {
  final CrewMember crewMember;

  const _FullCrewMemberTile({required this.crewMember});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Profile image
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 50,
              height: 60,
              child: crewMember.fullProfileUrl != null
                  ? CachedNetworkImage(
                      imageUrl: crewMember.fullProfileUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Name and job
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crewMember.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    // Use onSurface color for name
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  crewMember.job,
                  style: theme.textTheme.bodySmall?.copyWith(
                    // Use onSurfaceVariant for job
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<MovieDetailsProvider>(
      builder: (context, provider, child) {
        final reviews = provider.reviews;

        if (reviews.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.userReviews,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                // Use onSurface color for title
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            // Show first review
            _ReviewCard(review: reviews.first),

            if (reviews.length > 1) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _showAllReviewsBottomSheet(context, reviews);
                },
                child: Text(
                  AppLocalizations.of(context)!.viewAllReviews(reviews.length),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    // Use primary color for button text
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showAllReviewsBottomSheet(
    BuildContext context,
    List<MovieReview> reviews,
  ) {
    // Navigation bar is already hidden in movie details screen, no need to hide again
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Use theme background for the modal
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => _AllReviewsBottomSheet(
          reviews: reviews,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final MovieReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Use theme surfaceContainerLow for background
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        // Use theme outline or surfaceContainer for border
        border: Border.all(color: theme.colorScheme.surfaceContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                // Use theme surfaceContainer for background
                backgroundColor: theme.colorScheme.surfaceContainer,
                backgroundImage: review.authorDetails.fullAvatarUrl != null
                    ? CachedNetworkImageProvider(
                        review.authorDetails.fullAvatarUrl!,
                      )
                    : null,
                child: review.authorDetails.fullAvatarUrl == null
                    // Use onSurfaceVariant for icon
                    ? Icon(
                        Icons.person,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorDetails.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        // Use onSurface color for name
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      review.formattedCreatedAt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        // Use onSurfaceVariant for date
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating stars
              if (review.ratingStars > 0)
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < review.ratingStars
                          ? Icons.star
                          : Icons.star_border,
                      // Keep amber for stars
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Review content
          Text(
            review.getTruncatedContent(300),
            style: theme.textTheme.bodyMedium?.copyWith(
              // Use onSurface color for content
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllReviewsBottomSheet extends StatelessWidget {
  final List<MovieReview> reviews;
  final ScrollController scrollController;

  const _AllReviewsBottomSheet({
    required this.reviews,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // Use theme surface color for background
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              // Use theme surfaceContainer color for handle
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppLocalizations.of(context)!.allReviews(reviews.length),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                // Use onSurface color for header
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Content
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ReviewCard(review: review),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageGalleriesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<MovieDetailsProvider>(
      builder: (context, provider, child) {
        final backdrops = provider.backdrops;
        final posters = provider.posters;

        if (backdrops.isEmpty && posters.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.media,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                // Use onSurface color for title
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            // Backdrops section
            if (backdrops.isNotEmpty) ...[
              Text(
                AppLocalizations.of(context)!.backdrops,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  // Use onSurface color for section title
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: backdrops.take(10).length,
                  itemBuilder: (context, index) {
                    final backdrop = backdrops[index];
                    return _ImageCard(
                      image: backdrop,
                      onTap: () => _showImageGallery(context, backdrops, index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Posters section
            if (posters.isNotEmpty) ...[
              Text(
                AppLocalizations.of(context)!.posters,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  // Use onSurface color for section title
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: posters.take(10).length,
                  itemBuilder: (context, index) {
                    final poster = posters[index];
                    return _ImageCard(
                      image: poster,
                      aspectRatio: 0.67,
                      onTap: () => _showImageGallery(context, posters, index),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showImageGallery(
    BuildContext context,
    List<MovieImage> images,
    int initialIndex,
  ) {
    // Navigation bar is already hidden in movie details screen, no need to hide again
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _ImageGalleryScreen(images: images, initialIndex: initialIndex),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final MovieImage image;
  final double aspectRatio;
  final VoidCallback onTap;

  const _ImageCard({
    required this.image,
    this.aspectRatio = 1.78, // 16:9 default for backdrops
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150 * aspectRatio,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.1).toInt()), // Replaced withOpacity
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: image.mediumUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.image,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.broken_image,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageGalleryScreen extends StatefulWidget {
  final List<MovieImage> images;
  final int initialIndex;

  const _ImageGalleryScreen({required this.images, required this.initialIndex});

  @override
  State<_ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<_ImageGalleryScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep black background and white foreground for image gallery
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.imageGalleryTitle(_currentIndex + 1, widget.images.length)),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final image = widget.images[index];
          return InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: image.originalUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

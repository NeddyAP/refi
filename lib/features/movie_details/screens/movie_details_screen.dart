import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:refi/core/network/api_result.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/models/movie.dart';
import '../../../shared/models/movie_video.dart';
import '../../../shared/models/movie_cast.dart';
import '../../../shared/models/movie_review.dart';
import '../../../shared/models/movie_images.dart';
import '../../../features/favorites/providers/favorites_provider.dart';
import '../providers/movie_details_provider.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieDetailsProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                loading: () => const Scaffold(
                  body: LoadingWidget(message: 'Loading movie details...'),
                ),
              ) ??
              const Scaffold(
                body: LoadingWidget(message: 'Loading movie details...'),
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
            // Bottom padding to prevent content blockage by navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // Back button
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
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
                    placeholder: (context, url) =>
                        Container(color: theme.colorScheme.surfaceContainerHighest),
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

          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
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
                color: Colors.black.withOpacity(0.1),
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
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        genre.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
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
                      color: Colors.black,
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

        // Bookmark icon
        Consumer<FavoritesProvider>(
          builder: (context, favoritesProvider, child) {
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

            final isInWatchlist = favoritesProvider.isInWatchlist(movie.id);

            return IconButton(
              onPressed: () => favoritesProvider.toggleWatchlist(movie),
              icon: Icon(
                isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.black54,
                size: 28,
              ),
            );
          },
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

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black87,
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
          'Overview',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 12),

        if (movieDetails.overview != null && movieDetails.overview!.isNotEmpty)
          Text(
            movieDetails.overview!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              height: 1.5,
            ),
          )
        else
          Text(
            'No overview available.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
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
              'Trailers',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
        onTap: () async {
          final url = trailer.youtubeUrl;
          if (url != null) {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
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
                    color: Colors.black.withOpacity(0.1),
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
                  
                  // Play button overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
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
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Trailer type
            Text(
              trailer.type,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black54,
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
              'Top Billed Cast',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
                  color: Colors.black.withOpacity(0.1),
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
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Character name
          Text(
            castMember.character,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black54,
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
                'Full Cast & Crew',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              // Director info
              if (credits.director != null) ...[
                _CrewMemberRow(
                  title: 'Director',
                  crewMember: credits.director!,
                ),
                const SizedBox(height: 8),
              ],

              // Writers
              if (credits.writers.isNotEmpty) ...[
                _CrewMemberRow(
                  title: 'Writers',
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
                  'View Full Cast & Crew',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          error: (message, statusCode) => const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
        ) ?? const SizedBox.shrink();
      },
    );
  }

  void _showFullCastBottomSheet(BuildContext context, dynamic credits) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            additionalCount > 0
                ? '${crewMember.name} (+$additionalCount more)'
                : crewMember.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
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
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Full Cast & Crew',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
                  'Cast',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                ...credits.cast.map<Widget>((castMember) => _FullCastMemberTile(
                      castMember: castMember,
                    )),

                const SizedBox(height: 24),

                // Crew section
                Text(
                  'Crew',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                ...credits.crew.map<Widget>((crewMember) => _FullCrewMemberTile(
                      crewMember: crewMember,
                    )),

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
                    color: Colors.black87,
                  ),
                ),
                Text(
                  castMember.character,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
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
                    color: Colors.black87,
                  ),
                ),
                Text(
                  crewMember.job,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
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
              'User Reviews',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
                  'View All Reviews (${reviews.length})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue,
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

  void _showAllReviewsBottomSheet(BuildContext context, List<MovieReview> reviews) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
                backgroundColor: Colors.grey[300],
                backgroundImage: review.authorDetails.fullAvatarUrl != null
                    ? CachedNetworkImageProvider(review.authorDetails.fullAvatarUrl!)
                    : null,
                child: review.authorDetails.fullAvatarUrl == null
                    ? Icon(Icons.person, color: Colors.grey[600])
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
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      review.formattedCreatedAt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
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
                      index < review.ratingStars ? Icons.star : Icons.star_border,
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
              color: Colors.black87,
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
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
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'All Reviews (${reviews.length})',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
              'Media',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 16),

            // Backdrops section
            if (backdrops.isNotEmpty) ...[
              Text(
                'Backdrops',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
                'Posters',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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

  void _showImageGallery(BuildContext context, List<MovieImage> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageGalleryScreen(
          images: images,
          initialIndex: initialIndex,
        ),
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
              color: Colors.black.withOpacity(0.1),
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

  const _ImageGalleryScreen({
    required this.images,
    required this.initialIndex,
  });

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} of ${widget.images.length}'),
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

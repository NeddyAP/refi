import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:refi/core/network/api_result.dart';
import '../../../shared/widgets/rating_display.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/models/movie.dart';
import '../../../features/favorites/providers/favorites_provider.dart';
import '../providers/movie_details_provider.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({
    super.key,
    required this.movieId,
  });

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
            success: (movieDetails) => _MovieDetailsContent(movieDetails: movieDetails),
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
          ) ?? const Scaffold(
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
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // App bar with backdrop
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: movieDetails.fullBackdropUrl != null
                ? CachedNetworkImage(
                    imageUrl: movieDetails.fullBackdropUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceVariant,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.movie,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Container(
                    color: theme.colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.movie,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poster
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 120,
                        height: 180,
                        child: movieDetails.fullPosterUrl != null
                            ? CachedNetworkImage(
                                imageUrl: movieDetails.fullPosterUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: theme.colorScheme.surfaceVariant,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: theme.colorScheme.surfaceVariant,
                                  child: Icon(
                                    Icons.movie,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : Container(
                                color: theme.colorScheme.surfaceVariant,
                                child: Icon(
                                  Icons.movie,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Movie info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movieDetails.title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          if (movieDetails.tagline != null && movieDetails.tagline!.isNotEmpty)
                            Text(
                              movieDetails.tagline!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),

                          const SizedBox(height: 12),

                          // Rating
                          RatingDisplay(
                            rating: movieDetails.voteAverage,
                            size: 18,
                          ),

                          const SizedBox(height: 8),

                          // Release date and runtime
                          if (movieDetails.releaseYear != null)
                            Text(
                              movieDetails.releaseYear!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),

                          if (movieDetails.formattedRuntime != null)
                            Text(
                              movieDetails.formattedRuntime!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Action buttons
                _ActionButtons(movieDetails: movieDetails),

                const SizedBox(height: 24),

                // Genres
                if (movieDetails.genres.isNotEmpty) ...[
                  Text(
                    'Genres',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: movieDetails.genres.map<Widget>((genre) {
                      return Chip(
                        label: Text(genre.name),
                        backgroundColor: theme.colorScheme.surfaceVariant,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Overview
                if (movieDetails.overview != null && movieDetails.overview!.isNotEmpty) ...[
                  Text(
                    'Overview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movieDetails.overview!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                ],

                // Additional info
                _AdditionalInfo(movieDetails: movieDetails),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final dynamic movieDetails;

  const _ActionButtons({required this.movieDetails});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
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
          genreIds: movieDetails.genres.map<int>((g) => g.id as int).toList(),
          adult: movieDetails.adult,
          originalLanguage: movieDetails.originalLanguage,
          originalTitle: movieDetails.originalTitle,
          popularity: movieDetails.popularity,
          video: movieDetails.video,
        );

        final isFavorite = favoritesProvider.isFavorite(movie.id);
        final isInWatchlist = favoritesProvider.isInWatchlist(movie.id);

        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => favoritesProvider.toggleFavorite(movie),
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                label: Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => favoritesProvider.toggleWatchlist(movie),
                icon: Icon(isInWatchlist ? Icons.bookmark : Icons.bookmark_border),
                label: Text(isInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AdditionalInfo extends StatelessWidget {
  final dynamic movieDetails;

  const _AdditionalInfo({required this.movieDetails});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (movieDetails.status != null)
              _infoRow('Status', movieDetails.status!),

            if (movieDetails.originalLanguage.isNotEmpty)
              _infoRow('Original Language', movieDetails.originalLanguage.toUpperCase()),

            if (movieDetails.budget != null && movieDetails.budget! > 0)
              _infoRow('Budget', '\$${movieDetails.budget!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),

            if (movieDetails.revenue != null && movieDetails.revenue! > 0)
              _infoRow('Revenue', '\$${movieDetails.revenue!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

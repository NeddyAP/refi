import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:refi/core/network/api_result.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/models/movie.dart';
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
    final theme = Theme.of(context);

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
    final theme = Theme.of(context);

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
                        Container(color: theme.colorScheme.surfaceVariant),
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

            // Description section
            _DescriptionSection(movieDetails: movieDetails),

            const SizedBox(height: 32),

            // Rating input section
            _RatingInputSection(),

            const SizedBox(height: 32),

            // Rating and reviews section
            _RatingReviewsSection(),

            const SizedBox(height: 32),

            // Individual review
            _IndividualReviewSection(),

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
                      color: theme.colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.movie,
                        size: 24,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.movie,
                        size: 24,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Container(
                    color: theme.colorScheme.surfaceVariant,
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

              // Genre tag
              if (movieDetails.genres.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    movieDetails.genres.first.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ),

              const SizedBox(height: 8),
              Text(
                '4,6',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                  (index) =>
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                ),
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
          'Description',
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
            'No description available.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}

class _RatingInputSection extends StatefulWidget {
  @override
  State<_RatingInputSection> createState() => _RatingInputSectionState();
}

class _RatingInputSectionState extends State<_RatingInputSection> {
  int selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Berikan rating film ini',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Sampaikan pendapat Anda',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),

        const SizedBox(height: 16),

        // Star rating input
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedRating = index + 1;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  index < selectedRating ? Icons.star : Icons.star_border,
                  color: index < selectedRating ? Colors.amber : Colors.grey,
                  size: 32,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        Text(
          'Tulis ulasan',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}

class _RatingReviewsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating dan ulasan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Rating dan ulasan diverifikasi dan berasal dari orang yang menggunakan jenis perangkat yang sama dengan yang anda gunakan',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.black54,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 24),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall rating
            Column(
              children: [
                Text(
                  '4,6',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: List.generate(
                    5,
                    (index) =>
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 32),

            // Rating distribution
            Expanded(
              child: Column(
                children: [
                  _ratingBar(5, 0.7),
                  _ratingBar(4, 0.2),
                  _ratingBar(3, 0.05),
                  _ratingBar(2, 0.03),
                  _ratingBar(1, 0.02),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ratingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars'),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndividualReviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // User icon
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Neddy',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      // Star rating
                      ...List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        '01/10/2020',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          'Film keluarga yang menyenangkan dengan pesan moral yang baik. Cocok untuk ditonton bersama keluarga di akhir pekan.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black87,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Text(
              'Apakah ulasan ini membantu?',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),

            const SizedBox(width: 16),

            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
              ),
              child: Text(
                'Ya',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.blue),
              ),
            ),

            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
              ),
              child: Text(
                'Tidak',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.blue),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

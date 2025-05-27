import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/widgets/movie_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/models/movie.dart';
import '../providers/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Refi',
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<HomeProvider>().refresh(),
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PopularMoviesSection(),
              SizedBox(height: 24),
              _NowPlayingSection(),
              SizedBox(height: 24),
              _TopRatedSection(),
              SizedBox(height: 24),
              _UpcomingSection(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularMoviesSection extends StatelessWidget {
  const _PopularMoviesSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return _MovieSection(
          title: 'Popular Movies',
          result: provider.popularMovies,
          onRetry: () => provider.retrySection('popular'),
        );
      },
    );
  }
}

class _NowPlayingSection extends StatelessWidget {
  const _NowPlayingSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return _MovieSection(
          title: 'Now Playing',
          result: provider.nowPlayingMovies,
          onRetry: () => provider.retrySection('nowPlaying'),
        );
      },
    );
  }
}

class _TopRatedSection extends StatelessWidget {
  const _TopRatedSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return _MovieSection(
          title: 'Top Rated',
          result: provider.topRatedMovies,
          onRetry: () => provider.retrySection('topRated'),
        );
      },
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return _MovieSection(
          title: 'Upcoming',
          result: provider.upcomingMovies,
          onRetry: () => provider.retrySection('upcoming'),
        );
      },
    );
  }
}

class _MovieSection extends StatelessWidget {
  final String title;
  final ApiResult<MovieResponse>? result;
  final VoidCallback onRetry;

  const _MovieSection({
    required this.title,
    required this.result,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: result != null 
            ? result!.when(
                success: (movieResponse) {
                  if (movieResponse.results.isEmpty) {
                    return const Center(
                      child: Text('No movies available'),
                    );
                  }
                  
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movieResponse.results.length,
                    itemBuilder: (context, index) {
                      final movie = movieResponse.results[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: MovieCard(
                          movie: movie,
                          onTap: () => AppRouter.goToMovieDetails(context, movie.id),
                        ),
                      );
                    },
                  );
                },
                error: (message, statusCode) => Center(
                  child: ErrorDisplayWidget(
                    message: message,
                    onRetry: onRetry,
                  ),
                ),
                loading: () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: MovieCardSkeleton(),
                    );
                  },
                ),
              )
            : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

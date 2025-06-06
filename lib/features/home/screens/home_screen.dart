import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/models/movie.dart';
import '../providers/home_provider.dart';
import '../widgets/content_carousel.dart';
import 'all_items_screen.dart';
import '../../../features/auth/services/tmdb_auth_service.dart';
import '../../../features/auth/models/auth_user.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentCarouselIndex = 0;
  Timer? _autoSlideTimer;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().initialize();
      _startAutoSlide();
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_userInteracting && _pageController.hasClients) {
        final provider = context.read<HomeProvider>();
        final movieCount =
            provider.upcomingMovies?.when(
              success: (movieResponse) => movieResponse.results.length > 5
                  ? 5
                  : movieResponse.results.length,
              error: (_, __) => 5,
              loading: () => 5,
            ) ??
            5;

        if (movieCount > 1) {
          final nextIndex = (_currentCarouselIndex + 1) % movieCount;
          _pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _stopAutoSlide() {
    setState(() {
      _userInteracting = true;
    });

    // Resume auto-slide after 5 seconds of inactivity
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _userInteracting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<HomeProvider>().refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header and Carousel Section with Stack
              Stack(
                children: [
                  // Movie Carousel Background
                  _MovieCarouselSection(
                    pageController: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentCarouselIndex = index;
                      });
                    },
                    onUserInteraction: _stopAutoSlide,
                    currentIndex: _currentCarouselIndex,
                  ),
                  // Header overlay
                  _HeaderSection(currentCarouselIndex: _currentCarouselIndex),
                ],
              ),
              // Content Section with curved top
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Frequently Visited Section using ContentCarousel
                    Consumer<HomeProvider>(
                      builder: (context, provider, child) {
                        return ContentCarousel(
                          title: AppLocalizations.of(context)!.frequentlyVisited,
                          apiResult: provider.nowPlayingMovies,
                          sectionKey: 'nowPlaying',
                          onRetry: () => provider.retrySection('nowPlaying'),
                          collectionType: CollectionType.nowPlaying,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Recommendations Section using ContentCarousel
                    Consumer<HomeProvider>(
                      builder: (context, provider, child) {
                        return ContentCarousel(
                          title: AppLocalizations.of(context)!.recommendations,
                          apiResult: provider.topRatedMovies,
                          sectionKey: 'topRated',
                          onRetry: () => provider.retrySection('topRated'),
                          collectionType: CollectionType.topRated,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // New Content Carousels
                    Consumer<HomeProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            // Trending Today
                            ContentCarousel(
                              title: AppLocalizations.of(context)!.trendingToday,
                              apiResult: provider.trendingToday,
                              sectionKey: 'trendingToday',
                              onRetry: () =>
                                  provider.retrySection('trendingToday'),
                              collectionType: CollectionType.trendingToday,
                            ),
                            const SizedBox(height: 24),

                            // Trending This Week
                            ContentCarousel(
                              title: AppLocalizations.of(context)!.trendingThisWeek,
                              apiResult: provider.trendingThisWeek,
                              sectionKey: 'trendingThisWeek',
                              onRetry: () =>
                                  provider.retrySection('trendingThisWeek'),
                              collectionType: CollectionType.trendingThisWeek,
                            ),
                            const SizedBox(height: 24),

                            // Latest Trailers
                            ContentCarousel(
                              title: AppLocalizations.of(context)!.latestTrailers,
                              apiResult: provider.latestTrailers,
                              sectionKey: 'latestTrailers',
                              onRetry: () =>
                                  provider.retrySection('latestTrailers'),
                              collectionType: CollectionType.latestTrailers,
                            ),
                            const SizedBox(height: 24),

                            // Popular on Streaming
                            ContentCarousel(
                              title: AppLocalizations.of(context)!.popularOnStreaming,
                              apiResult: provider.popularOnStreaming,
                              sectionKey: 'popularOnStreaming',
                              onRetry: () =>
                                  provider.retrySection('popularOnStreaming'),
                              collectionType: CollectionType.popularOnStreaming,
                            ),
                            const SizedBox(height: 24),

                            // Popular On TV
                            ContentCarousel(
                              title: AppLocalizations.of(context)!.popularOnTv,
                              apiResult: provider.popularOnTv,
                              sectionKey: 'popularOnTv',
                              onRetry: () =>
                                  provider.retrySection('popularOnTv'),
                              collectionType: CollectionType.popularOnTv,
                            ),
                            const SizedBox(height: 24),

                            // Available For Rent
                            ContentCarousel(
                              title: AppLocalizations.of(context)!.availableForRent,
                              apiResult: provider.availableForRent,
                              sectionKey: 'availableForRent',
                              onRetry: () =>
                                  provider.retrySection('availableForRent'),
                              collectionType: CollectionType.availableForRent,
                            ),
                            const SizedBox(height: 24),

                            // Currently In Theaters
                            ContentCarousel(
                              title: AppLocalizations.of(context)!.currentlyInTheaters,
                              apiResult: provider.currentlyInTheaters,
                              sectionKey: 'currentlyInTheaters',
                              onRetry: () =>
                                  provider.retrySection('currentlyInTheaters'),
                              collectionType:
                                  CollectionType.currentlyInTheaters,
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final int currentCarouselIndex;

  const _HeaderSection({required this.currentCarouselIndex});

  AuthUser? get tmdbUser => TmdbAuthService().currentUser;

  String userName(BuildContext context) {
    if (tmdbUser != null && tmdbUser!.displayName.isNotEmpty) {
      return tmdbUser!.displayName;
    }
    return AppLocalizations.of(context)!.guest;
  }

  Widget userAvatar(BuildContext context) {
    final user = tmdbUser;
    if (user != null && user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(user.avatarUrl!),
      );
    } else if (user != null && user.displayName.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          user.initials,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        child: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.outline,
          size: 20,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            // Profile Picture and Greeting
            Flexible(
              flex: 3,
              child: Row(
                children: [
                  userAvatar(context),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.hiUserGreeting(userName(context)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Settings (Gear) Icon
            Flexible(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      AppRouter.goToProfile(context);
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 22,
                    ),
                    tooltip: AppLocalizations.of(context)!.profileAndSettings,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieCarouselSection extends StatefulWidget {
  final PageController pageController;
  final Function(int) onPageChanged;
  final VoidCallback onUserInteraction;
  final int currentIndex;

  const _MovieCarouselSection({
    required this.pageController,
    required this.onPageChanged,
    required this.onUserInteraction,
    required this.currentIndex,
  });

  @override
  State<_MovieCarouselSection> createState() => _MovieCarouselSectionState();
}

class _MovieCarouselSectionState extends State<_MovieCarouselSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          height: 500,
          child: Stack(
            children: [
              // Background Image/Carousel
              provider.upcomingMovies?.when(
                    success: (movieResponse) {
                      if (movieResponse.results.isEmpty) {
                        return _buildPlaceholderCarousel();
                      }

                      // Display only the first 5 newest movies
                      final newestMovies = movieResponse.results
                          .take(5)
                          .toList();

                      return PageView.builder(
                        controller: widget.pageController,
                        onPageChanged: (index) {
                          widget.onUserInteraction();
                          widget.onPageChanged(index);
                        },
                        itemCount: newestMovies.length,
                        itemBuilder: (context, index) {
                          final movie = newestMovies[index];
                          return GestureDetector(
                            onTap: () =>
                                AppRouter.goToMovieDetails(context, movie.id),
                            onPanDown: (_) => widget.onUserInteraction(),
                            child: Stack(
                              children: [
                                // Background Image
                                movie.fullBackdropUrl != null
                                    ? Image.network(
                                        movie.fullBackdropUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildPlaceholderImage(),
                                      )
                                    : _buildPlaceholderImage(),
                                // Darker Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.4),
                                        Colors.black.withOpacity(0.6),
                                        Colors.black.withOpacity(0.8),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    error: (message, statusCode) => _buildPlaceholderCarousel(),
                    loading: () => _buildPlaceholderCarousel(),
                  ) ??
                  _buildPlaceholderCarousel(),

              // Overlay Content
              Positioned(
                bottom: 100,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    // Search Section
                    Text(
                      AppLocalizations.of(context)!.whatMovieDoYouWantToSee,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.findTheMovieYouLike,
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            AppRouter.goToExploreWithSearch(context, value.trim());
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pagination Dots
                    Consumer<HomeProvider>(
                      builder: (context, provider, child) {
                        final movieCount =
                            provider.upcomingMovies?.when(
                              success: (movieResponse) =>
                                  movieResponse.results.length > 5
                                  ? 5
                                  : movieResponse.results.length,
                              error: (_, __) => 3,
                              loading: () => 3,
                            ) ??
                            3;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            movieCount,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.currentIndex == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Rating and Movie Info
              Positioned(
                bottom: 30,
                right: 16,
                child: Consumer<HomeProvider>(
                  builder: (context, provider, child) {
                    return provider.upcomingMovies?.when(
                          success: (movieResponse) {
                            if (movieResponse.results.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            final newestMovies = movieResponse.results
                                .take(5)
                                .toList();
                            final movie =
                                newestMovies[widget.currentIndex < newestMovies.length
                                    ? widget.currentIndex
                                    : 0];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade400,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
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
                                        movie.voteAverage.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.family,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          error: (_, __) => const SizedBox.shrink(),
                          loading: () => const SizedBox.shrink(),
                        ) ??
                        const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderCarousel() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade300, Colors.blue.shade700],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade300, Colors.blue.shade700],
        ),
      ),
      child: const Center(
        child: Icon(Icons.movie, size: 100, color: Colors.white54),
      ),
    );
  }
}

class _CompactMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;

  const _CompactMovieCard({required this.movie, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
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
                      child: movie.fullPosterUrl != null
                          ? Image.network(
                              movie.fullPosterUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.movie,
                                      size: 50,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                                  ),
                            )
                          : Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.movie,
                                size: 50,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                    ),
                  ),
                  // Bookmark Icon
                  Positioned(
                    top: 6,
                    right: 6,
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
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Movie Title
            Text(
              movie.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Genre
            Text(
              AppLocalizations.of(context)!.family, // Placeholder genre
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
}

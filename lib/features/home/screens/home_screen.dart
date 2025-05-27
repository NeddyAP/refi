import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/models/movie.dart';
import '../../../shared/models/user.dart';
import '../providers/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                child: const Column(
                  children: [
                    SizedBox(height: 24),
                    _CategoriesSection(),
                    SizedBox(height: 24),
                    _FrequentlyVisitedSection(),
                    SizedBox(height: 24),
                    _RecommendationsSection(),
                    SizedBox(height: 100), // Add bottom padding for floating nav
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

  // Mock function to check if user is logged in
  // In a real app, this would come from an authentication provider
  User? get currentUser => null; // Return null for guest user
  
  String get userName {
    if (currentUser != null) {
      return currentUser!.name;
    }
    return "Guest";
  }

  Widget userAvatar(BuildContext context) {
    if (currentUser?.photoUrl != null) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(currentUser!.photoUrl!),
      );
    } else if (currentUser != null) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          currentUser!.initials,
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
                      'Hi, $userName!',
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
            
            // Notification Bell
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
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
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

class _MovieCarouselSection extends StatelessWidget {
  final PageController pageController;
  final Function(int) onPageChanged;
  final int currentIndex;

  const _MovieCarouselSection({
    required this.pageController,
    required this.onPageChanged,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Container(
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
                  final newestMovies = movieResponse.results.take(5).toList();
                  
                  return PageView.builder(
                    controller: pageController,
                    onPageChanged: onPageChanged,
                    itemCount: newestMovies.length,
                    itemBuilder: (context, index) {
                      final movie = newestMovies[index];
                      return GestureDetector(
                        onTap: () => AppRouter.goToMovieDetails(context, movie.id),
                        child: Stack(
                          children: [
                            // Background Image
                            movie.fullBackdropUrl != null
                                ? Image.network(
                                    movie.fullBackdropUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) =>
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
              ) ?? _buildPlaceholderCarousel(),
              
              // Overlay Content
              Positioned(
                bottom: 100,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    // Search Section
                    const Text(
                      'what movie do you want to see?',
                      style: TextStyle(
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
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'find the movie you like',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          suffixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Pagination Dots
                    Consumer<HomeProvider>(
                      builder: (context, provider, child) {
                        final movieCount = provider.upcomingMovies?.when(
                          success: (movieResponse) => movieResponse.results.length > 5 ? 5 : movieResponse.results.length,
                          error: (_, __) => 3,
                          loading: () => 3,
                        ) ?? 3;
                        
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
                                color: currentIndex == index
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
                        final newestMovies = movieResponse.results.take(5).toList();
                        final movie = newestMovies[currentIndex < newestMovies.length ? currentIndex : 0];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                            const Text(
                              'Family',
                              style: TextStyle(
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
                    ) ?? const SizedBox.shrink();
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
          colors: [
            Colors.blue.shade300,
            Colors.blue.shade700,
          ],
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
          colors: [
            Colors.blue.shade300,
            Colors.blue.shade700,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.movie,
          size: 100,
          color: Colors.white54,
        ),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    final categories = ['Family', 'Drama', 'Action', 'Thriller', 'Horror', 'Anime', 'Cartoon', 'Adventure'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategori',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {
                  AppRouter.goToExplore(context);
                },
                child: Text(
                  'Lihat Semua',
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
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: false, // Always false
                  onSelected: (selected) {
                    // Navigate to explore screen with selected category
                    AppRouter.goToExploreWithCategory(context, category);
                  },
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1), // Keep this color or change if needed
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5), // Always use outline color
                    width: 1, // Always use width 1
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant, // Always use onSurfaceVariant color
                    fontWeight: FontWeight.w500, // Always use w500
                    fontSize: 13,
                  ),
                  elevation: 0, // Always 0
                  shadowColor: Colors.transparent, // Always transparent
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FrequentlyVisitedSection extends StatelessWidget {
  const _FrequentlyVisitedSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Sering Dikunjungi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: provider.nowPlayingMovies?.when(
                success: (movieResponse) {
                  if (movieResponse.results.isEmpty) {
                    return const Center(child: Text('No movies available'));
                  }
                  
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movieResponse.results.length,
                    itemBuilder: (context, index) {
                      final movie = movieResponse.results[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _CompactMovieCard(
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
                    onRetry: () => provider.retrySection('nowPlaying'),
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
              ) ?? const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Rekomendasi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: provider.topRatedMovies?.when(
                success: (movieResponse) {
                  if (movieResponse.results.isEmpty) {
                    return const Center(child: Text('No movies available'));
                  }
                  
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movieResponse.results.length,
                    itemBuilder: (context, index) {
                      final movie = movieResponse.results[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _CompactMovieCard(
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
                    onRetry: () => provider.retrySection('topRated'),
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
              ) ?? const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

class _CompactMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;

  const _CompactMovieCard({
    required this.movie,
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
            // Movie Poster
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceVariant,
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
                                    color: Theme.of(context).colorScheme.surfaceVariant,
                                    child: Icon(
                                      Icons.movie,
                                      size: 50,
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                            )
                          : Container(
                              color: Theme.of(context).colorScheme.surfaceVariant,
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
              'Family', // Placeholder genre
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

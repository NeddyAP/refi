import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../profile/providers/profile_provider.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() async {
    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.completeOnboarding();
    
    if (mounted) {
      context.go(AppConstants.homeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60), // Placeholder for symmetry
                  // Page indicators
                  Row(
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      );
                    }),
                  ),
                  // Skip button
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  OnboardingPage(
                    image: 'assets/images/onboarding_1.png',
                    title: localizations.welcomeToApp(localizations.appTitle),
                    subtitle: 'Discover amazing movies and TV shows from around the world',
                    primaryColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                  ),
                  OnboardingPage(
                    image: 'assets/images/onboarding_2.png',
                    title: localizations.exploreMoviesButton,
                    subtitle: 'Browse through thousands of movies with advanced search and filtering options',
                    primaryColor: theme.colorScheme.secondary,
                    backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.1),
                  ),
                  OnboardingPage(
                    image: 'assets/images/onboarding_3.png',
                    title: 'Create Your Collection',
                    subtitle: 'Save your favorite movies and create watchlists to keep track of what you want to watch',
                    primaryColor: theme.colorScheme.tertiary,
                    backgroundColor: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.1),
                  ),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  _currentPage > 0
                      ? TextButton.icon(
                          onPressed: _previousPage,
                          icon: Icon(
                            Icons.arrow_back,
                            color: theme.colorScheme.onSurface,
                          ),
                          label: Text(
                            'Previous',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        )
                      : const SizedBox(width: 100),

                  // Next/Get Started button
                  ElevatedButton.icon(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: Icon(
                      _currentPage == 2 ? Icons.check : Icons.arrow_forward,
                    ),
                    label: Text(
                      _currentPage == 2 ? 'Get Started' : 'Next',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

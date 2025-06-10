import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color backgroundColor;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor,
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // Illustration placeholder
            Container(
              width: size.width * 0.7,
              height: size.width * 0.7,              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  _getIconForImage(image),
                  size: size.width * 0.3,
                  color: primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Subtitle
            Text(
              subtitle,              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  IconData _getIconForImage(String imagePath) {
    if (imagePath.contains('onboarding_1')) {
      return Icons.movie_creation_outlined;
    } else if (imagePath.contains('onboarding_2')) {
      return Icons.explore_outlined;
    } else if (imagePath.contains('onboarding_3')) {
      return Icons.favorite_outline;
    }
    return Icons.movie_outlined;
  }
}

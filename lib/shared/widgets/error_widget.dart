import 'package:flutter/material.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryText;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      message: 'Please check your internet connection and try again.',
      onRetry: onRetry,
      icon: Icons.wifi_off,
      retryText: 'Retry',
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class NoResultsWidget extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onClearSearch;

  const NoResultsWidget({
    super.key,
    this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Results Found',
      message: searchQuery != null
          ? 'No movies found for "$searchQuery". Try a different search term.'
          : 'No movies found. Try adjusting your filters.',
      icon: Icons.search_off,
      action: onClearSearch != null
          ? TextButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
            )
          : null,
    );
  }
}

class NoFavoritesWidget extends StatelessWidget {
  final VoidCallback? onExplore;

  const NoFavoritesWidget({
    super.key,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Favorites Yet',
      message: 'Start exploring movies and add them to your favorites to see them here.',
      icon: Icons.favorite_border,
      action: onExplore != null
          ? ElevatedButton.icon(
              onPressed: onExplore,
              icon: const Icon(Icons.explore),
              label: const Text('Explore Movies'),
            )
          : null,
    );
  }
}

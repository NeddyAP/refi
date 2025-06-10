import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../providers/navigation_visibility_provider.dart';
import '../../l10n/app_localizations.dart';

class BottomNavigationWrapper extends StatelessWidget {
  final Widget child;

  const BottomNavigationWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      backgroundColor: Colors.transparent,
      extendBody:
          true, // This allows the body to extend behind the bottom navigation
      bottomNavigationBar: Consumer<NavigationVisibilityProvider>(
        builder: (context, navProvider, child) {
          return AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            offset: navProvider.isVisible ? Offset.zero : const Offset(0, 1),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              opacity: navProvider.isVisible ? 1.0 : 0.0,
              child: const CustomBottomNavigationBar(),
            ),
          );
        },
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final localizations = AppLocalizations.of(context)!;

    int getCurrentIndex() {
      switch (currentLocation) {
        case AppConstants.homeRoute:
          return 0;
        case AppConstants.exploreRoute:
          return 1;
        case AppConstants.favoritesRoute:
          return 2;
        case AppConstants.profileRoute:
          return 3;
        default:
          return 0;
      }
    }

    void onTap(int index) {
      switch (index) {
        case 0:
          context.go(AppConstants.homeRoute);
          break;
        case 1:
          context.go(AppConstants.exploreRoute);
          break;
        case 2:
          context.go(AppConstants.favoritesRoute);
          break;
        case 3:
          context.go(AppConstants.profileRoute);
          break;
      }
    }

    final currentIndex = getCurrentIndex();

    return Container(
      // Add padding for floating effect
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      child: Container(
        height: 68,
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(
            34,
          ), // Fully rounded for pill shape
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withAlpha((255 * 0.1).toInt()), // Replaced withOpacity
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.08).toInt()), // Replaced withOpacity
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.05).toInt()), // Replaced withOpacity
              blurRadius: 48,
              offset: const Offset(0, 16),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _OptimizedNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: localizations.homeLabel,
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
                showBackground: false,
              ),
              _OptimizedNavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search_rounded,
                label: localizations.exploreLabel,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _OptimizedNavItem(
                icon: Icons.favorite_outline,
                activeIcon: Icons.favorite_rounded,
                label: localizations.favoritesLabel,
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _OptimizedNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person_rounded,
                label: localizations.profileLabel,
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptimizedNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool showBackground;

  const _OptimizedNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    // Cache colors to avoid repeated lookups
    final activeColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Optimize touch detection
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive && showBackground ? 16 : 8,
          vertical: 4.5,
        ),
        decoration: BoxDecoration(
          color: isActive && showBackground ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive && showBackground
              ? [
                  BoxShadow(
                    color: activeColor.withAlpha((255 * 0.3).toInt()), // Replaced withOpacity
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: isActive && showBackground
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(activeIcon, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    color: isActive ? activeColor : inactiveColor,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? activeColor : inactiveColor,
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Keep the legacy BottomNavigationBarWidget for compatibility
class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomBottomNavigationBar();
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

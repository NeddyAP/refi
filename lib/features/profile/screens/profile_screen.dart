import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profile',
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User info section
                _UserInfoSection(provider: provider),

                const SizedBox(height: 32),

                // Settings section
                _SettingsSection(provider: provider),

                const SizedBox(height: 32),

                // About section
                const _AboutSection(),

                const SizedBox(height: 32), // Add space before sign out button

                // Sign Out button (moved here)
                Consumer<AuthProvider>( // Use Consumer to access AuthProvider
                  builder: (context, authProvider, child) {
                    if (authProvider.isAuthenticated) {
                      return ElevatedButton.icon( // Use ElevatedButton.icon for icon
                        onPressed: () => _showSignOutDialog(context, authProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context).colorScheme.onError,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        icon: const Icon(Icons.logout), // Add logout icon
                        label: const Text('Sign Out'),
                      );
                    } else {
                      return const SizedBox.shrink(); // Hide button if not authenticated
                    }
                  },
                ),


                // Bottom padding for navigation bar
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // Keep _showSignOutDialog here as it's used by the button in this state
  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  final ProfileProvider provider;

  const _UserInfoSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final isAuthenticated = authProvider.isAuthenticated;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary,
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child: user?.hasProfilePhoto != true
                      ? Text(
                          isAuthenticated ? (user?.initials ?? 'U') : 'G',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),

                const SizedBox(height: 16),

                // Name
                Text(
                  isAuthenticated ? (user?.displayName ?? 'User') : 'Guest User',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Status/Username
                Text(
                  isAuthenticated
                      ? (user?.username != null ? '@${user!.username}' : 'TMDB User')
                      : 'Browsing as guest',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 8),

                // Session status for authenticated users
                if (isAuthenticated && user != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 16,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.isGuest ? 'Guest Session' : 'TMDB Account',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Action buttons
                if (isAuthenticated) ...[
                  // Authenticated user buttons (Sign Out button removed from here)
                  // Add other authenticated user actions here if needed
                ] else ...[
                  // Guest user buttons
                  ElevatedButton.icon( // Sign In button
                    onPressed: () => context.push(AppConstants.loginRoute),
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In'),
                    style: ElevatedButton.styleFrom(
                       minimumSize: const Size(double.infinity, 48), // Make it full width
                    ),
                  ),
                  const SizedBox(height: 12), // Add spacing
                  TextButton( // Sign Up text button
                    onPressed: () => _launchTmdbSignUpUrl(context),
                    child: const Text('Sign Up at TMDB'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // New function to launch the TMDB sign-up URL
  void _launchTmdbSignUpUrl(BuildContext context) async {
    final Uri url = Uri.parse('https://www.themoviedb.org/signup');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Handle error, e.g., show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open $url'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final ProfileProvider provider;

  const _SettingsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Dark mode toggle
          ListTile(
            leading: Icon(
              provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(
              provider.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
            ),
            trailing: Switch(
              value: provider.isDarkMode,
              onChanged: (value) => provider.toggleTheme(),
            ),
          ),

          // Notifications (placeholder)
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifications'),
            subtitle: Text('Manage notification preferences'),
            trailing: Icon(Icons.chevron_right),
          ),

          // Language (placeholder)
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text('English'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'About',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),

          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.chevron_right),
          ),

          const ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('Terms of Service'),
            trailing: Icon(Icons.chevron_right),
          ),

          const ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Help & Support'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

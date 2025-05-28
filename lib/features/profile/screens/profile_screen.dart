// Author: Neddy AP
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
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
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.profileScreenTitle,
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
                Consumer<AuthProvider>(
                  // Use Consumer to access AuthProvider
                  builder: (context, authProvider, child) {
                    if (authProvider.isAuthenticated) {
                      return ElevatedButton.icon(
                        // Use ElevatedButton.icon for icon
                        onPressed: () =>
                            _showSignOutDialog(context, authProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        icon: const Icon(Icons.logout), // Add logout icon
                        label: Text(AppLocalizations.of(context)!.signOut),
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
        title: Text(AppLocalizations.of(context)!.signOutDialogTitle),
        content: Text(AppLocalizations.of(context)!.signOutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
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
            child: Text(AppLocalizations.of(context)!.signOut),
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
                  isAuthenticated
                      ? (user?.displayName ?? 'User')
                      : AppLocalizations.of(context)!.guestUser,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Status/Username
                Text(
                  isAuthenticated
                      ? (user?.username != null
                            ? '@${user!.username}'
                            : AppLocalizations.of(context)!.tmdbUser)
                      : AppLocalizations.of(context)!.browsingAsGuest,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 8),

                // Session status for authenticated users
                if (isAuthenticated && user != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
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
                          user.isGuest
                              ? AppLocalizations.of(context)!.guestSession
                              : AppLocalizations.of(context)!.tmdbAccount,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),

                // --- Additional TMDB details ---
                if (isAuthenticated && user != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (user.createdAt != null)
                        _ProfileInfoTile(
                          icon: Icons.calendar_today,
                          label: AppLocalizations.of(context)!.joined,
                          value: user.createdAt!
                              .toLocal()
                              .toString()
                              .split(' ')
                              .first,
                        ),
                      _ProfileInfoTile(
                        icon: Icons.language,
                        label: AppLocalizations.of(context)!.language,
                        value: user.iso639_1,
                      ),
                      _ProfileInfoTile(
                        icon: Icons.flag,
                        label: AppLocalizations.of(context)!.region,
                        value: user.iso3166_1,
                      ),
                      _ProfileInfoTile(
                        icon: Icons.privacy_tip,
                        label: AppLocalizations.of(context)!.adult,
                        value: user.includeAdult
                            ? AppLocalizations.of(context)!.yes
                            : AppLocalizations.of(context)!.no,
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Action buttons
                if (isAuthenticated) ...[
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.push(AppConstants.accountInfoRoute),
                    icon: const Icon(Icons.info_outline),
                    label: Text(AppLocalizations.of(context)!.viewAccountInfo),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ] else ...[
                  // Guest user buttons
                  ElevatedButton.icon(
                    // Sign In button
                    onPressed: () => context.push(AppConstants.loginRoute),
                    icon: const Icon(Icons.login),
                    label: Text(AppLocalizations.of(context)!.signIn),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        48,
                      ), // Make it full width
                    ),
                  ),
                  const SizedBox(height: 12), // Add spacing
                  TextButton(
                    // Sign Up text button
                    onPressed: () => _launchTmdbSignUpUrl(context),
                    child: Text(AppLocalizations.of(context)!.signUpAtTmdb),
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.couldNotOpen(url.toString()),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
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
              AppLocalizations.of(context)!.settings,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // --- New settings navigation tiles ---
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppLocalizations.of(context)!.accountInformation),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppConstants.accountInfoRoute),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(AppLocalizations.of(context)!.privacySettings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppConstants.privacySettingsRoute),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context)!.appLanguage),
            trailing: DropdownButton<String>(
              value: provider.appLanguageCode,
              items: const [
                // Hardcoded for now, will use localization later
                DropdownMenuItem(
                  value: 'en',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🇺🇸', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text('EN'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'id',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🇮🇩', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text('ID'),
                    ],
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  provider.setAppLanguage(newValue);
                }
              },
            ),
          ),
          // --- Theme toggle remains ---
          ListTile(
            leading: Icon(
              provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: Text(AppLocalizations.of(context)!.darkMode),
            subtitle: Text(
              provider.isDarkMode
                  ? AppLocalizations.of(context)!.darkThemeEnabled
                  : AppLocalizations.of(context)!.lightThemeEnabled,
            ),
            trailing: Switch(
              value: provider.isDarkMode,
              onChanged: (value) => provider.toggleTheme(),
            ),
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
              AppLocalizations.of(context)!.about,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppLocalizations.of(context)!.appVersion),
            subtitle: const Text(AppConstants.appVersion),
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(AppLocalizations.of(context)!.privacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Replace with actual Privacy Policy URL
              _launchUrl(context, 'https://example.com/privacy');
            },
          ),

          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(AppLocalizations.of(context)!.termsOfService),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Replace with actual Terms of Service URL
              _launchUrl(context, 'https://example.com/terms');
            },
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(AppLocalizations.of(context)!.helpAndSupport),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Replace with actual Help & Support URL
              _launchUrl(context, 'https://example.com/help');
            },
          ),
          const SizedBox(height: 24), // Add some spacing
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () => _launchUrl(
                context,
                AppLocalizations.of(context)!.authorWebsiteUrl,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context)!.madeByText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to launch a URL
  void _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.couldNotOpen(urlString),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

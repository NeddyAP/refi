import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../providers/profile_provider.dart';

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
              ],
            ),
          );
        },
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                provider.userInitials,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Name
            Text(
              provider.displayName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Status
            Text(
              provider.isGuest ? 'Guest User' : 'Signed In',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sign in/out button
            if (provider.isGuest)
              ElevatedButton(
                onPressed: () => _showSignInDialog(context),
                child: const Text('Sign In as Guest'),
              )
            else
              OutlinedButton(
                onPressed: () => provider.signOut(),
                child: const Text('Sign Out'),
              ),
          ],
        ),
      ),
    );
  }

  void _showSignInDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In as Guest'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ProfileProvider>().signInAsGuest(controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
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

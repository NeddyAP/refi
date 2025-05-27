import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Account Information')),
      body: user == null
          ? const Center(child: Text('No user information available.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Username'),
                  subtitle: Text(user.username ?? '-'),
                ),
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text('Name'),
                  subtitle: Text(user.name ?? '-'),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Account Created'),
                  subtitle: Text(
                    user.createdAt?.toLocal().toString().split(' ').first ??
                        '-',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: Text(user.iso639_1),
                ),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Region'),
                  subtitle: Text(user.iso3166_1),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Adult Content'),
                  subtitle: Text(user.includeAdult ? 'Enabled' : 'Disabled'),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _launchTmdbAccountSettingsUrl(context),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Manage Account on TMDB Website'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Note: Some account details like username and email can only be updated directly on the TMDB website.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  void _launchTmdbAccountSettingsUrl(BuildContext context) async {
    final Uri url = Uri.parse(
      'https://www.themoviedb.org/settings/account',
    ); // Assuming this is the correct URL
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open $url'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

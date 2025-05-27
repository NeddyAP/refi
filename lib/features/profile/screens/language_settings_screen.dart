import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language & Region')),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          // Example list of supported languages (replace with actual supported languages)
          final List<String> supportedLanguages = ['en', 'id'];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('App Language'),
                subtitle: Text(profileProvider.appLanguageCode),
                trailing: DropdownButton<String>(
                  value: profileProvider.appLanguageCode,
                  items: supportedLanguages.map((String languageCode) {
                    return DropdownMenuItem<String>(
                      value: languageCode,
                      child: Text(
                        languageCode.toUpperCase(),
                      ), // Display language code
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      profileProvider.setAppLanguage(newValue);
                    }
                  },
                ),
              ),
              // Add more language/region settings here if needed
              // For TMDB account language/region, you might just display the value from AuthUser
              // and direct the user to the TMDB website to change it, similar to Account Info.
            ],
          );
        },
      ),
    );
  }
}

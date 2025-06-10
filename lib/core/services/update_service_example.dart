import 'package:refi/core/services/update_service.dart';

/// Example usage of UpdateService
class UpdateServiceExample {
  final UpdateService _updateService = UpdateService();

  /// Example method to check for updates and handle the result
  Future<void> checkForUpdates() async {
    try {
      final result = await _updateService.isUpdateAvailable();
      
      if (result.isAvailable) {
        print('Update available!');
        print('Current version: ${result.currentVersion}');
        print('Latest version: ${result.latestVersion}');
        print('Download URL: ${result.downloadUrl}');
        
        // Here you could show a dialog to the user
        // or trigger an automatic download
        
      } else {
        print('App is up to date!');
        print('Current version: ${result.currentVersion}');
        if (result.latestVersion != null) {
          print('Latest version: ${result.latestVersion}');
        }
      }
      
      if (result.error != null) {
        print('Warning: ${result.error}');
      }
      
    } on UpdateServiceException catch (e) {
      print('Error checking for updates: $e');
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  /// Example method to get just the latest release info
  Future<void> getLatestReleaseInfo() async {
    try {
      final release = await _updateService.fetchLatestRelease();
      
      if (release != null) {
        print('Latest release found:');
        print('Version: ${release['version']}');
        print('Download URL: ${release['downloadUrl']}');
      } else {
        print('No release information found');
      }
      
    } on UpdateServiceException catch (e) {
      print('Error fetching release info: $e');
    }
  }
}
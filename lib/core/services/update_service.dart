import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Custom exception for UpdateService errors
class UpdateServiceException implements Exception {
  final String message;
  
  const UpdateServiceException(this.message);
  
  @override
  String toString() => 'UpdateServiceException: $message';
}

/// Result of update availability check
class UpdateResult {
  final bool isAvailable;
  final String currentVersion;
  final String? latestVersion;
  final String? downloadUrl;
  final String? error;

  const UpdateResult({
    required this.isAvailable,
    required this.currentVersion,
    this.latestVersion,
    this.downloadUrl,
    this.error,
  });

  @override
  String toString() {
    return 'UpdateResult(isAvailable: $isAvailable, currentVersion: $currentVersion, '
           'latestVersion: $latestVersion, downloadUrl: $downloadUrl, error: $error)';
  }
}

/// Service for checking app updates from GitHub releases
class UpdateService {
  static const String _githubApiUrl = 'https://api.github.com/repos/neddyap/refi/releases/latest';
  final Dio _dio;

  UpdateService({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetches the latest release information from GitHub
  /// Returns a map containing version and download URL
  Future<Map<String, String>?> fetchLatestRelease() async {
    try {
      final response = await _dio.get(_githubApiUrl);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final String tagName = data['tag_name'] ?? '';
        
        // Find the APK asset download URL
        String? downloadUrl;
        final assets = data['assets'] as List?;
        
        if (assets != null) {
          for (final asset in assets) {
            final String name = asset['name'] ?? '';
            if (name.toLowerCase().endsWith('.apk')) {
              downloadUrl = asset['browser_download_url'];
              break;
            }
          }
        }
        
        if (tagName.isNotEmpty && downloadUrl != null) {
          return {
            'version': tagName,
            'downloadUrl': downloadUrl,
          };
        }
      }
      
      return null;
    } on DioException catch (e) {
      throw UpdateServiceException('Failed to fetch latest release: ${e.message}');
    } catch (e) {
      throw UpdateServiceException('Unexpected error while fetching latest release: $e');
    }
  }

  /// Checks if an update is available
  /// Returns UpdateResult with availability status and download URL if available
  Future<UpdateResult> isUpdateAvailable() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // Fetch latest release
      final latestRelease = await fetchLatestRelease();
      
      if (latestRelease == null) {
        return UpdateResult(
          isAvailable: false,
          currentVersion: currentVersion,
          latestVersion: null,
          downloadUrl: null,
          error: 'Could not fetch latest release information',
        );
      }
      
      final latestVersion = latestRelease['version']!;
      final downloadUrl = latestRelease['downloadUrl']!;
      
      // Compare versions
      final isUpdateAvailable = _compareVersions(currentVersion, latestVersion) < 0;
      
      return UpdateResult(
        isAvailable: isUpdateAvailable,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        downloadUrl: isUpdateAvailable ? downloadUrl : null,
      );
      
    } on UpdateServiceException {
      rethrow;
    } catch (e) {
      throw UpdateServiceException('Failed to check for updates: $e');
    }
  }

  /// Compares two version strings
  /// Returns -1 if version1 < version2, 0 if equal, 1 if version1 > version2
  int _compareVersions(String version1, String version2) {
    // Remove 'v' prefix if present
    final v1 = version1.startsWith('v') ? version1.substring(1) : version1;
    final v2 = version2.startsWith('v') ? version2.substring(1) : version2;
    
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    // Ensure both version lists have the same length
    while (parts1.length < parts2.length) {
      parts1.add(0);
    }
    while (parts2.length < parts1.length) {
      parts2.add(0);
    }
    
    for (int i = 0; i < parts1.length; i++) {
      if (parts1[i] < parts2[i]) {
        return -1;
      } else if (parts1[i] > parts2[i]) {
        return 1;
      }
    }
    
    return 0; // Versions are equal
  }

  /// Downloads and installs the APK from the given URL
  /// Returns true if successful, false otherwise
  Future<bool> downloadAndInstallApk(String downloadUrl, {
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      // Only proceed on Android platform
      if (!Platform.isAndroid) {
        throw UpdateServiceException('APK installation is only supported on Android');
      }

      // Get temporary directory for storing the APK
      final tempDir = await getTemporaryDirectory();
      final fileName = 'refi_update_${DateTime.now().millisecondsSinceEpoch}.apk';
      final filePath = '${tempDir.path}/$fileName';

      // Download the APK file
      await _dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          receiveTimeout: const Duration(minutes: 10), // 10 minutes timeout
          headers: {
            'User-Agent': 'Refi-Flutter-App/1.0',
          },
        ),
      );

      // Verify the file was downloaded successfully
      final file = File(filePath);
      if (!await file.exists()) {
        throw UpdateServiceException('Downloaded file not found');
      }

      // Check file size (basic validation)
      final fileSize = await file.length();
      if (fileSize < 1024 * 1024) { // Less than 1MB seems suspicious for an APK
        throw UpdateServiceException('Downloaded file size too small, possible corruption');
      }

      // Open the APK file for installation
      final result = await OpenFilex.open(filePath);
      
      if (result.type == ResultType.done) {
        return true;
      } else {
        throw UpdateServiceException('Failed to open APK for installation: ${result.message}');
      }

    } on DioException catch (e) {
      throw UpdateServiceException('Download failed: ${e.message}');
    } catch (e) {
      throw UpdateServiceException('Failed to download and install APK: $e');
    }
  }

  /// Downloads the APK and returns the file path
  /// Useful for scenarios where you want to handle installation separately
  Future<String> downloadApk(String downloadUrl, {
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      // Only proceed on Android platform
      if (!Platform.isAndroid) {
        throw UpdateServiceException('APK download is only supported on Android');
      }

      // Get temporary directory for storing the APK
      final tempDir = await getTemporaryDirectory();
      final fileName = 'refi_update_${DateTime.now().millisecondsSinceEpoch}.apk';
      final filePath = '${tempDir.path}/$fileName';

      // Download the APK file
      await _dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          receiveTimeout: const Duration(minutes: 10), // 10 minutes timeout
          headers: {
            'User-Agent': 'Refi-Flutter-App/1.0',
          },
        ),
      );

      // Verify the file was downloaded successfully
      final file = File(filePath);
      if (!await file.exists()) {
        throw UpdateServiceException('Downloaded file not found');
      }

      // Check file size (basic validation)
      final fileSize = await file.length();
      if (fileSize < 1024 * 1024) { // Less than 1MB seems suspicious for an APK
        throw UpdateServiceException('Downloaded file size too small, possible corruption');
      }

      return filePath;

    } on DioException catch (e) {
      throw UpdateServiceException('Download failed: ${e.message}');
    } catch (e) {
      throw UpdateServiceException('Failed to download APK: $e');
    }
  }

  /// Installs an APK from the given file path
  Future<bool> installApk(String filePath) async {
    try {
      // Only proceed on Android platform
      if (!Platform.isAndroid) {
        throw UpdateServiceException('APK installation is only supported on Android');
      }

      // Verify the file exists
      final file = File(filePath);
      if (!await file.exists()) {
        throw UpdateServiceException('APK file not found at: $filePath');
      }

      // Open the APK file for installation
      final result = await OpenFilex.open(filePath);
      
      if (result.type == ResultType.done) {
        return true;
      } else {
        throw UpdateServiceException('Failed to open APK for installation: ${result.message}');
      }

    } catch (e) {
      throw UpdateServiceException('Failed to install APK: $e');
    }
  }

  /// Cleans up downloaded APK files from temporary directory
  Future<void> cleanupDownloadedFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (final file in files) {
        if (file is File && file.path.contains('refi_update_') && file.path.endsWith('.apk')) {
          try {
            await file.delete();
            if (kDebugMode) {
              print('Cleaned up: ${file.path}');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to delete ${file.path}: $e');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cleanup downloaded files: $e');
      }
    }
  }
}
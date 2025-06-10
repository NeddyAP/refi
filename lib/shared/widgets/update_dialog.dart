import 'package:flutter/material.dart';
import 'package:refi/core/services/update_service.dart';

/// A reusable dialog widget for displaying app update notifications
class UpdateDialog extends StatefulWidget {
  final String latestVersion;
  final String downloadUrl;
  final VoidCallback? onUpdatePressed;
  final VoidCallback? onLaterPressed;
  final UpdateService? updateService;

  const UpdateDialog({
    super.key,
    required this.latestVersion,
    required this.downloadUrl,
    this.onUpdatePressed,
    this.onLaterPressed,
    this.updateService,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();

  /// Static method to show the update dialog
  static Future<void> show({
    required BuildContext context,
    required String latestVersion,
    required String downloadUrl,
    VoidCallback? onUpdatePressed,
    VoidCallback? onLaterPressed,
    UpdateService? updateService,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return UpdateDialog(
          latestVersion: latestVersion,
          downloadUrl: downloadUrl,
          onUpdatePressed: onUpdatePressed,
          onLaterPressed: onLaterPressed,
          updateService: updateService,
        );
      },
    );
  }
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadStatus = '';
  late UpdateService _updateService;

  @override
  void initState() {
    super.initState();
    _updateService = widget.updateService ?? UpdateService();
  }

  Future<void> _handleUpdatePressed() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatus = 'Starting download...';
    });

    try {
      // Show downloading status
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading update ${widget.latestVersion}...'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );

      final success = await _updateService.downloadAndInstallApk(
        widget.downloadUrl,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
              _downloadStatus = 'Downloading... ${(received / total * 100).toStringAsFixed(1)}%';
            });
          }
        },
      );

      if (success) {
        setState(() {
          _downloadStatus = 'Download complete, installing...';
        });

        // Show installation prompt
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Download complete! Please install the APK.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Installation failed');
      }

    } catch (e) {
      setState(() {
        _isDownloading = false;
        _downloadStatus = 'Download failed';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.system_update,
            color: colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Update Available',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A new version (${widget.latestVersion}) is available!',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          if (_isDownloading) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _downloadStatus,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  if (_downloadProgress > 0) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: colorScheme.outline.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Update now to get the latest features and improvements.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!_isDownloading)
          TextButton(
            onPressed: widget.onLaterPressed ?? () => Navigator.of(context).pop(),
            child: Text(
              'Later',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ElevatedButton(
          onPressed: _isDownloading ? null : (widget.onUpdatePressed ?? _handleUpdatePressed),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isDownloading ? colorScheme.outline : colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: _isDownloading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Update Now'),
        ),
      ],
    );
  }
}
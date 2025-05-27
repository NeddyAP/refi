import 'package:flutter/material.dart';

/// Provider that manages the visibility state of the bottom navigation bar.
/// This provider controls when the bottom navigation should be hidden
/// (e.g., when modal dialogs or full-screen overlays are active).
class NavigationVisibilityProvider extends ChangeNotifier {
  bool _isVisible = true;

  /// Whether the bottom navigation bar should be visible
  bool get isVisible => _isVisible;

  /// Shows the bottom navigation bar with animation
  void show() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  /// Hides the bottom navigation bar with animation
  void hide() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  /// Toggles the visibility state of the bottom navigation bar
  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  /// Sets the visibility state directly
  void setVisibility(bool visible) {
    if (_isVisible != visible) {
      _isVisible = visible;
      notifyListeners();
    }
  }
}
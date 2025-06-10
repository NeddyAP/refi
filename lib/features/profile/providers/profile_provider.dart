import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class ProfileProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  String _appLanguageCode = 'en'; // Default language
  String get appLanguageCode => _appLanguageCode;

  bool _isGuest = true;
  bool get isGuest => _isGuest;

  String? _userName;
  String? get userName => _userName;

  String? _userEmail;
  String? get userEmail => _userEmail;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isFirstLaunch = true;
  bool get isFirstLaunch => _isFirstLaunch;

    /// Initialize profile data
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadThemePreference();
    await _loadLanguagePreference();
    await _loadUserData();
    await _loadFirstLaunchStatus();

    _isInitialized = true;
    notifyListeners();
  }

  /// Load theme preference
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(AppConstants.themeKey) ?? false;
    } catch (e) {
      // print('Error loading theme preference: $e');
      // TODO: Implement proper logging
      _isDarkMode = false;
    }
  }

  /// Load language preference
  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _appLanguageCode =
          prefs.getString(AppConstants.languageKey) ??
          'en'; // Default to English on error
    } catch (e) {
      // print('Error loading language preference: $e');
      // TODO: Implement proper logging
      _appLanguageCode = 'en';
    }
  }

  /// Load user data
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('user_name');
      _userEmail = prefs.getString('user_email');
      _isGuest = _userName == null && _userEmail == null;
    } catch (e) {
      // print('Error loading user data: $e');
      // TODO: Implement proper logging
      _isGuest = true;
    }
  }

  /// Load first launch status
  Future<void> _loadFirstLaunchStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isFirstLaunch = prefs.getBool(AppConstants.isFirstLaunchKey) ?? true;
    } catch (e) {
      // print('Error loading first launch status: $e');
      // TODO: Implement proper logging
      _isFirstLaunch = true;
    }
  }

  /// Toggle theme mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.themeKey, _isDarkMode);
    } catch (e) {
      // print('Error saving theme preference: $e');
      // TODO: Implement proper logging
    }

    notifyListeners();
  }

  /// Set app language
  Future<void> setAppLanguage(String languageCode) async {
    _appLanguageCode = languageCode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.languageKey, _appLanguageCode);
    } catch (e) {
      // print('Error saving language preference: $e');
      // TODO: Implement proper logging
    }
    notifyListeners();
  }

  /// Sign in as guest (demo mode)
  Future<void> signInAsGuest(String name) async {
    _userName = name;
    _userEmail = null;
    _isGuest = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.remove('user_email');
    } catch (e) {
      // print('Error saving guest data: $e');
      // TODO: Implement proper logging
    }

    notifyListeners();
  }

  /// Sign out
  Future<void> signOut() async {
    _userName = null;
    _userEmail = null;
    _isGuest = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name');
      await prefs.remove('user_email');
    } catch (e) {
      // print('Error clearing user data: $e');
      // TODO: Implement proper logging
    }

    notifyListeners();
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    _isFirstLaunch = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.isFirstLaunchKey, false);
    } catch (e) {
      // print('Error saving onboarding completion: $e');
      // TODO: Implement proper logging
    }
    notifyListeners();
  }

  /// Reset onboarding status (useful for testing)
  Future<void> resetOnboarding() async {
    _isFirstLaunch = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.isFirstLaunchKey, true);
    } catch (e) {
      // print('Error resetting onboarding status: $e');
      // TODO: Implement proper logging
    }
    notifyListeners();
  }

  /// Get display name
  String get displayName {
    if (_userName != null) return _userName!;
    if (_userEmail != null) return _userEmail!.split('@').first;
    return 'Guest User';
  }

  /// Get user initials
  String get userInitials {
    final name = displayName;
    if (name.isEmpty) return 'GU';

    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return name.substring(0, 2).toUpperCase();
    }
  }
}

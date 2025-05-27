import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class ProfileProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isGuest = true;
  bool get isGuest => _isGuest;

  String? _userName;
  String? get userName => _userName;

  String? _userEmail;
  String? get userEmail => _userEmail;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize profile data
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadThemePreference();
    await _loadUserData();

    _isInitialized = true;
    notifyListeners();
  }

  /// Load theme preference
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(AppConstants.themeKey) ?? false;
    } catch (e) {
      print('Error loading theme preference: $e');
      _isDarkMode = false;
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
      print('Error loading user data: $e');
      _isGuest = true;
    }
  }

  /// Toggle theme mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.themeKey, _isDarkMode);
    } catch (e) {
      print('Error saving theme preference: $e');
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
      print('Error saving guest data: $e');
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
      print('Error clearing user data: $e');
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

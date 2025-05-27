import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../../core/constants/app_constants.dart';

/// Login screen with TMDB username/password authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hasNavigatedBack = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your TMDB username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _signIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthProvider>().signInWithEmailAndPassword(
            email: _usernameController.text.trim(), // Using email param for username
            password: _passwordController.text,
          );
    }
  }

  void _goToTmdbRegister() {
    // Open TMDB registration page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please register at https://www.themoviedb.org/signup'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _goToTmdbPasswordReset() {
    // Open TMDB password reset page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please reset your password at https://www.themoviedb.org/reset-password'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Navigate back when authentication is successful
            if (authProvider.isAuthenticated && !_hasNavigatedBack) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_hasNavigatedBack) {
                  _hasNavigatedBack = true;
                  context.pop(); // Go back to previous screen
                }
              });
            }

            // Show error if any
            if (authProvider.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(authProvider.errorMessage!),
                    backgroundColor: theme.colorScheme.error,
                    action: SnackBarAction(
                      label: 'Dismiss',
                      textColor: theme.colorScheme.onError,
                      onPressed: () {
                        authProvider.clearError();
                      },
                    ),
                  ),
                );
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // App Logo/Title
                    Icon(
                      Icons.movie,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Welcome to ${AppConstants.appName}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in with your TMDB account to discover amazing movies',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Username field
                    AuthTextField(
                      label: 'TMDB Username',
                      hint: 'Enter your TMDB username',
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      validator: _validateUsername,
                      prefixIcon: const Icon(Icons.person_outlined),
                    ),

                    const SizedBox(height: 24),

                    // Password field
                    AuthTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      obscureText: true,
                      validator: _validatePassword,
                      prefixIcon: const Icon(Icons.lock_outlined),
                    ),

                    const SizedBox(height: 16),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _goToTmdbPasswordReset,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sign in button
                    AuthButton(
                      text: 'Sign In with TMDB',
                      onPressed: _signIn,
                      isLoading: authProvider.isLoading,
                    ),

                    const SizedBox(height: 24),

                    // Info about guest access
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You can browse movies without signing in',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in to rate movies and create watchlists',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sign up link
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have a TMDB account? ",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: _goToTmdbRegister,
                          child: Text(
                            'Sign Up at TMDB',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

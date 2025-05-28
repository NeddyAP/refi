import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.enterTmdbUsernameValidation;
    }
    if (value.length < 3) {
      return l10n.usernameMinLengthValidation;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.enterPasswordValidation;
    }
    if (value.length < 6) {
      return l10n.passwordMinLengthValidation;
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
    final l10n = AppLocalizations.of(context)!;
    // Open TMDB registration page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.pleaseRegisterAt),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _goToTmdbPasswordReset() {
    final l10n = AppLocalizations.of(context)!;
    // Open TMDB password reset page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.pleaseResetPasswordAt),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
                      label: l10n.dismiss,
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
                      l10n.welcomeToApp(AppConstants.appName),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      l10n.signInWithTmdbSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Username field
                    AuthTextField(
                      label: l10n.tmdbUsername,
                      hint: l10n.enterTmdbUsername,
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      validator: _validateUsername,
                      prefixIcon: const Icon(Icons.person_outlined),
                    ),

                    const SizedBox(height: 24),

                    // Password field
                    AuthTextField(
                      label: l10n.password,
                      hint: l10n.enterPassword,
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
                          l10n.forgotPassword,
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
                      text: l10n.signInWithTmdb,
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
                            l10n.browseModeInfo,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.signInBenefits,
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
                          l10n.noTmdbAccount,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: _goToTmdbRegister,
                          child: Text(
                            l10n.signUpAtTmdb,
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

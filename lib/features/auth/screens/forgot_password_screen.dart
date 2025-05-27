import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

/// Forgot password screen for password reset
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  void _sendPasswordReset() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().sendPasswordResetEmail(
              _emailController.text.trim(),
            );
        setState(() {
          _emailSent = true;
        });
      } catch (e) {
        // Error handling is done in the provider
      }
    }
  }

  void _goBack() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Icon
                  Icon(
                    _emailSent ? Icons.mark_email_read : Icons.lock_reset,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  if (_emailSent) ...[
                    // Success state
                    Text(
                      'Check Your Email',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'We\'ve sent a password reset link to:',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      _emailController.text.trim(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Please check your email and follow the instructions to reset your password. Don\'t forget to check your spam folder.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    AuthButton(
                      text: 'Back to Sign In',
                      onPressed: _goBack,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    AuthButton(
                      text: 'Resend Email',
                      onPressed: () {
                        setState(() {
                          _emailSent = false;
                        });
                      },
                      isOutlined: true,
                    ),
                  ] else ...[
                    // Input state
                    Text(
                      'Forgot Password?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Enter your email address and we\'ll send you a link to reset your password.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    Form(
                      key: _formKey,
                      child: AuthTextField(
                        label: 'Email',
                        hint: 'Enter your email address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    AuthButton(
                      text: 'Send Reset Link',
                      onPressed: _sendPasswordReset,
                      isLoading: authProvider.isLoading,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    AuthButton(
                      text: 'Back to Sign In',
                      onPressed: _goBack,
                      isOutlined: true,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

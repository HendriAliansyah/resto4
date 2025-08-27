// lib/views/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../utils/snackbar.dart';
import '../../utils/constants.dart';
import '../widgets/loading_indicator.dart';

class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final isLoading = ref.watch(authControllerProvider);

    void handleResetPassword() async {
      if (emailController.text.trim().isEmpty) {
        showSnackBar(
          context,
          'Please enter your email address.',
          isError: true,
        );
        return;
      }
      try {
        await ref
            .read(authControllerProvider.notifier)
            .sendPasswordResetEmail(email: emailController.text.trim());
        if (!context.mounted) return;
        showSnackBar(
          context,
          "A password reset link has been sent to your email. Please check your inbox.",
        );
        context.pop();
      } catch (e) {
        if (!context.mounted) return;
        showSnackBar(
          context,
          "Failed to send reset link. Please try again.",
          isError: true,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(UIStrings.forgotPasswordTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Dismiss the keyboard when the user taps on an empty space
            FocusScope.of(context).unfocus();
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Receive a reset link',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter your account email below to receive a password reset link.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: UIStrings.emailLabel,
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  if (isLoading)
                    const LoadingIndicator()
                  else
                    ElevatedButton(
                      onPressed: handleResetPassword,
                      child: const Text(UIStrings.resetButton),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

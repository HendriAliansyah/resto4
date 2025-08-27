// lib/views/onboarding/onboarding_screen.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:resto2/providers/auth_providers.dart';
import 'package:resto2/providers/restaurant_provider.dart';
import 'package:resto2/utils/constants.dart';
import 'package:resto2/utils/snackbar.dart';
import '../widgets/loading_indicator.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final authController = ref.read(authControllerProvider.notifier);

    final restaurantIdController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isRequestLoading = useState(false);

    void handleSendRequest() async {
      if (formKey.currentState?.validate() ?? false) {
        isRequestLoading.value = true;
        try {
          // Call the new, simpler controller method.
          await ref
              .read(restaurantControllerProvider.notifier)
              .requestToJoinRestaurant(
                restaurantId: restaurantIdController.text.trim(),
              );

          if (context.mounted) {
            showSnackBar(context, UIStrings.requestSentSuccessfully);
            restaurantIdController.clear();
          }
        } catch (e) {
          if (!context.mounted) return;

          // **THE FIX IS HERE:**
          // We now check the 'details' field of the exception. This is reliable.
          if (e is FirebaseFunctionsException &&
              e.details?['reason'] == 'RESTAURANT_NOT_FOUND') {
            showSnackBar(context, UIStrings.restaurantNotFound, isError: true);
          } else {
            // Show a generic message for all other errors.
            showSnackBar(context, UIStrings.unexpectedError, isError: true);
          }
        } finally {
          if (context.mounted) {
            isRequestLoading.value = false;
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(UIStrings.welcome),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Dismiss the keyboard when the user taps on an empty space
            FocusScope.of(context).unfocus();
          },
          child: currentUserAsync.when(
            data: (appUser) {
              if (appUser == null) {
                return const LoadingIndicator();
              }

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        UIStrings.welcomeUser.replaceFirst(
                          '{name}',
                          appUser.displayName ?? 'User',
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed:
                            () => context.push(AppRoutes.manageRestaurant),
                        child: const Text(UIStrings.createNewRestaurant),
                      ),
                      const SizedBox(height: 24),
                      const Text(UIStrings.or, style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),
                      const Text(
                        UIStrings.joinExistingRestaurant,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: formKey,
                        child: TextFormField(
                          controller: restaurantIdController,
                          decoration: const InputDecoration(
                            labelText: UIStrings.restaurantId,
                            hintText: UIStrings.restaurantIdHint,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid Restaurant ID';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isRequestLoading.value)
                        const LoadingIndicator()
                      else
                        ElevatedButton(
                          // THE FIX: The call now correctly matches the function signature.
                          onPressed: handleSendRequest,
                          child: const Text(UIStrings.sendJoinRequest),
                        ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const LoadingIndicator(),
            error:
                (err, stack) => Center(
                  child: Text('Error loading user profile: ${err.toString()}'),
                ),
          ),
        ),
      ),
    );
  }
}

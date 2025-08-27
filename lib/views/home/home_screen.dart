// lib/views/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/views/widgets/app_drawer.dart'; // Import the new drawer
import 'package:resto2/views/widgets/loading_indicator.dart';
import 'package:resto2/views/widgets/notification_bell.dart';
import '../../providers/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: const [NotificationBell()],
      ),
      drawer: const AppDrawer(), // Add the drawer here
      body: SafeArea(
        child: currentUser.when(
          data: (appUser) {
            if (appUser == null || appUser.role == null) {
              return const LoadingIndicator();
            }

            // You can customize the body of the home screen further here.
            // For now, we'll keep the welcome message.
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, ${appUser.displayName ?? 'User'}! 👋',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Your role: ${appUser.role!.name}'),
                ],
              ),
            );
          },
          loading: () => const LoadingIndicator(),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

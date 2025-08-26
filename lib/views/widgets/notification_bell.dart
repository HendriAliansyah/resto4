import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/notification_provider.dart';
import '../../utils/constants.dart';

class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the stream of notifications
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return notificationsAsync.when(
      data: (notifications) {
        // Calculate the number of unread notifications
        final unreadCount =
            notifications.where((n) => n.isRead == false).length;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                context.push(AppRoutes.notifications);
              },
            ),
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
      loading:
          () => IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
      error:
          (err, stack) => IconButton(
            icon: const Icon(Icons.notifications_off_outlined),
            onPressed: () {},
          ),
    );
  }
}

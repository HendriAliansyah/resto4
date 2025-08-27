// lib/views/notifications/notification_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:resto2/models/notification_payload.dart';
import 'package:resto2/utils/constants.dart';
import 'package:resto2/views/widgets/app_drawer.dart';
import '../../providers/notification_provider.dart';
import '../widgets/loading_indicator.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final notificationController = ref.read(notificationControllerProvider);

    void showNotificationDialog(String title, String content) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title)),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(content, style: const TextStyle(height: 1.5)),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(UIStrings.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(UIStrings.notificationsTitle)),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_paused_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        UIStrings.noNotifications,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        UIStrings.noNotificationsMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final String subtitle = switch (notification.payload) {
                  GenericPayload p => p.message,
                  JoinRequestPayload _ => UIStrings.joinRequestMessage,
                  JoinRequestResponsePayload p =>
                    p.wasApproved
                        ? UIStrings.requestApproved
                        : UIStrings.requestRejected,
                  StockEditPayload p => // Updated this line
                  '${p.itemName}: ${p.quantityBefore.toStringAsFixed(2)} ➔ ${p.quantityAfter.toStringAsFixed(2)}',
                  _ => UIStrings.newNotification,
                };

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        notification.isRead
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight:
                          notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMd().add_jm().format(
                          notification.createdAt.toDate(),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    if (!notification.isRead) {
                      notificationController.markNotificationAsRead(
                        notification.id,
                      );
                    }

                    switch (notification.payload) {
                      case JoinRequestPayload():
                        context.push(AppRoutes.manageStaff);
                        break;
                      case StockEditPayload p: // Updated this case
                        final change = p.quantityChanged;
                        final changeText =
                            '${change > 0 ? '+' : ''}${change.toStringAsFixed(2)}';
                        final content =
                            'User: ${p.userDisplayName}\n'
                            'Item: ${p.itemName}\n\n'
                            'Quantity Before: ${p.quantityBefore.toStringAsFixed(2)}\n'
                            'Quantity After: ${p.quantityAfter.toStringAsFixed(2)}\n'
                            'Change: $changeText\n\n'
                            'Reason: ${p.reason}';
                        showNotificationDialog(notification.title, content);
                        break;
                      case GenericPayload p:
                        showNotificationDialog(notification.title, p.message);
                        break;
                      case JoinRequestResponsePayload():
                        showNotificationDialog(notification.title, subtitle);
                        break;
                      default:
                        showNotificationDialog(notification.title, subtitle);
                        break;
                    }
                  },
                );
              },
            );
          },
          loading: () => const LoadingIndicator(),
          error:
              (err, stack) =>
                  const Center(child: Text('Could not load notifications.')),
        ),
      ),
    );
  }
}

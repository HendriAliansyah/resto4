import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'auth_providers.dart'; // We need the auth state

// Provides an instance of NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Provides the stream of notifications for the currently logged-in user
final notificationsStreamProvider =
    StreamProvider.autoDispose<List<NotificationModel>>((ref) {
      final authState = ref.watch(authStateChangeProvider);
      final notificationService = ref.watch(notificationServiceProvider);

      if (authState.asData?.value?.uid != null) {
        return notificationService.getNotificationsStream(
          authState.asData!.value!.uid,
        );
      }

      return Stream.value([]); // Return an empty stream if no user is logged in
    });

// Provides the notification controller
final notificationControllerProvider = Provider((ref) {
  return NotificationController(ref);
});

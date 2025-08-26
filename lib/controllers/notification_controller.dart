import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_providers.dart';
import '../providers/notification_provider.dart';

class NotificationController {
  final Ref _ref;

  NotificationController(this._ref);

  Future<void> markNotificationAsRead(String notificationId) async {
    final user = _ref.read(authStateChangeProvider).asData?.value;
    if (user == null) return; // Not logged in, do nothing

    try {
      // **THE FIX IS HERE:**
      // The method name is now corrected to match the service.
      await _ref
          .read(notificationServiceProvider)
          .markNotificationAsRead(user.uid, notificationId);
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }
}

// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resto2/models/notification_model.dart';
import 'package:resto2/models/notification_payload.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => NotificationModel.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<void> markNotificationAsRead(
    String userId,
    String notificationId,
  ) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Sends a notification to a specific user.
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required NotificationPayload payload,
  }) async {
    final notification = NotificationModel(
      id: '',
      title: title,
      createdAt: Timestamp.now(),
      isRead: false,
      payload: payload,
    );

    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notification.toJson());
  }

  /// Finds all owners and admins of a restaurant and sends them a notification.
  Future<void> sendNotificationToRestaurantAdmins({
    required String restaurantId,
    required String title,
    required NotificationPayload payload,
  }) async {
    // 1. Find all users who are admins or owners of this restaurant.
    final querySnapshot =
        await _db
            .collection('users')
            .where('restaurantId', isEqualTo: restaurantId)
            .where('role', whereIn: ['owner', 'admin'])
            .get();

    if (querySnapshot.docs.isEmpty) {
      // No admins or owners found for this restaurant.
      return;
    }

    // 2. Create a batch write to send a notification to each admin.
    final batch = _db.batch();
    final notification = NotificationModel(
      id: '',
      title: title,
      createdAt: Timestamp.now(),
      isRead: false,
      payload: payload,
    );

    for (final adminDoc in querySnapshot.docs) {
      final notificationRef =
          adminDoc.reference.collection('notifications').doc();
      batch.set(notificationRef, notification.toJson());
    }

    // 3. Commit the batch write.
    await batch.commit();
  }

  /// Finds all owners and managers of a restaurant and sends them a notification.
  Future<void> sendNotificationToRestaurantManagers({
    required String restaurantId,
    required String title,
    required NotificationPayload payload,
  }) async {
    // 1. Find all users who are managers or owners of this restaurant.
    final querySnapshot =
        await _db
            .collection('users')
            .where('restaurantId', isEqualTo: restaurantId)
            .where('role', whereIn: ['owner', 'manager'])
            .get();

    if (querySnapshot.docs.isEmpty) {
      return;
    }

    // 2. Create a batch write to send a notification to each manager/owner.
    final batch = _db.batch();
    final notification = NotificationModel(
      id: '',
      title: title,
      createdAt: Timestamp.now(),
      isRead: false,
      payload: payload,
    );

    for (final doc in querySnapshot.docs) {
      final notificationRef = doc.reference.collection('notifications').doc();
      batch.set(notificationRef, notification.toJson());
    }

    // 3. Commit the batch write.
    await batch.commit();
  }
}

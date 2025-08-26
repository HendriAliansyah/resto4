import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/notification_payload.dart';
import 'package:resto2/models/role_permission_model.dart';
import 'package:resto2/providers/auth_providers.dart';
import 'package:resto2/providers/notification_provider.dart';
import 'package:resto2/providers/staff_provider.dart';

class StaffController {
  final Ref _ref;
  StaffController(this._ref);

  Future<void> updateStaffRole({
    required String userId,
    required UserRole newRole,
  }) async {
    await _ref
        .read(firestoreServiceProvider)
        .updateUserRole(uid: userId, role: newRole);
  }

  Future<void> setUserDisabledStatus({
    required String userId,
    required bool isDisabled,
  }) async {
    await _ref
        .read(firestoreServiceProvider)
        .updateUserDisabledStatus(uid: userId, isDisabled: isDisabled);
  }

  Future<void> approveJoinRequest({
    required String restaurantId,
    required String userId,
    required UserRole role,
  }) async {
    // 1. Update the user's document with the restaurant, role, and enabled status.
    await _ref
        .read(firestoreServiceProvider)
        .updateUserRestaurantAndRole(
          uid: userId,
          restaurantId: restaurantId,
          role: role,
        );

    // Also explicitly enable the user.
    await setUserDisabledStatus(userId: userId, isDisabled: false);

    // 2. Update the status of the join request to 'accepted'
    await _ref
        .read(staffServiceProvider)
        .updateJoinRequestStatus(
          restaurantId: restaurantId,
          userId: userId,
          isAccepted: true,
        );

    // 3. Send a notification to the user
    await _ref
        .read(notificationServiceProvider)
        .sendNotificationToUser(
          userId: userId,
          title: 'Request Approved!',
          payload: const JoinRequestResponsePayload(wasApproved: true),
        );
  }

  Future<void> rejectJoinRequest({
    required String restaurantId,
    required String userId,
  }) async {
    await _ref
        .read(staffServiceProvider)
        .updateJoinRequestStatus(
          restaurantId: restaurantId,
          userId: userId,
          isAccepted: false,
        );

    await _ref
        .read(notificationServiceProvider)
        .sendNotificationToUser(
          userId: userId,
          title: 'Request Rejected',
          payload: const JoinRequestResponsePayload(wasApproved: false),
        );
  }
}

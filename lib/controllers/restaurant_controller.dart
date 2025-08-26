import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/join_request_model.dart';
import 'package:resto2/models/notification_payload.dart';
import 'package:resto2/models/user_model.dart';
import 'package:resto2/providers/notification_provider.dart';
import '../models/restaurant_model.dart';
import '../providers/auth_providers.dart';
import '../providers/restaurant_provider.dart';
import '../providers/storage_provider.dart';

// Provider for the Cloud Functions instance
final functionsProvider = Provider((ref) => FirebaseFunctions.instance);

class RestaurantController extends StateNotifier<bool> {
  final Ref _ref;
  RestaurantController(this._ref) : super(false);

  Future<bool> saveDetails({
    required String name,
    required String address,
    required String phone,
    File? newLogoFile,
    String? existingLogoUrl,
  }) async {
    state = true;
    final user = _ref.read(currentUserProvider).asData?.value;
    if (user == null || user.restaurantId == null) {
      state = false;
      throw Exception('User or restaurant not found');
    }

    final existingRestaurant =
        _ref.read(restaurantStreamProvider).asData?.value;
    if (existingRestaurant == null) {
      state = false;
      throw Exception('Could not find existing restaurant data to update.');
    }

    final String restaurantId = user.restaurantId!;
    String? finalLogoUrl = existingLogoUrl;
    String? newLogoPath;

    try {
      if (newLogoFile != null) {
        newLogoPath = 'logos/$restaurantId/logo.jpg';
        finalLogoUrl = await _ref
            .read(storageServiceProvider)
            .uploadImage(newLogoPath, newLogoFile);
      }

      final restaurant = RestaurantModel(
        id: restaurantId,
        ownerId: existingRestaurant.ownerId,
        name: name,
        address: address,
        phone: phone,
        logoUrl: finalLogoUrl,
      );

      await _ref
          .read(restaurantServiceProvider)
          .saveRestaurantDetails(restaurant);

      state = false;
      return true;
    } catch (e) {
      if (newLogoPath != null) {
        await _ref.read(storageServiceProvider).deleteImage(newLogoPath);
      }
      state = false;
      rethrow;
    }
  }

  /// Submits a request and notifies all restaurant admins.
  Future<void> sendJoinRequestAndNotifyAdmins({
    required String restaurantId,
    required AppUser user,
  }) async {
    final request = JoinRequestModel(
      userId: user.uid,
      userDisplayName: user.displayName ?? 'No Name',
      userEmail: user.email,
      status: JoinRequestStatus.pending,
      createdAt: Timestamp.now(),
    );

    await _ref
        .read(restaurantServiceProvider)
        .submitJoinRequest(restaurantId: restaurantId, request: request);

    final title = 'New Join Request';
    await _ref
        .read(notificationServiceProvider)
        .sendNotificationToRestaurantAdmins(
          restaurantId: restaurantId,
          title: title,
          payload: const JoinRequestPayload(),
        );
  }

  Future<void> requestToJoinRestaurant({required String restaurantId}) async {
    try {
      final callable = _ref
          .read(functionsProvider)
          .httpsCallable('requestToJoinRestaurant');
      await callable.call({'restaurantId': restaurantId});
    } on FirebaseFunctionsException {
      // **THE FIX IS HERE:**
      // We now re-throw the original exception, preserving the error code.
      rethrow;
    } catch (e) {
      // For any other type of error, we can throw a generic message.
      throw Exception('An unknown error occurred while sending the request.');
    }
  }
}

// lib/controllers/auth_controller.dart

import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/restaurant_model.dart';
import 'package:resto2/models/role_permission_model.dart';
import 'package:resto2/providers/storage_provider.dart';
import 'package:resto2/services/restaurant_service.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthController extends StateNotifier<bool> {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final RestaurantService _restaurantService;
  final Ref _ref;

  AuthController(
    this._authService,
    this._firestoreService,
    this._restaurantService,
    this._ref,
  ) : super(false);

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = true;
    try {
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        final newUser = AppUser(
          uid: user.uid,
          email: email,
          displayName: displayName,
          role: null,
          restaurantId: null,
          isDisabled: false,
        );

        await _firestoreService.addUser(newUser);
        state = false;
        return true;
      }
      state = false;
      return false;
    } catch (e) {
      state = false;
      rethrow;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = true;
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        final sessionToken = const Uuid().v4();
        await _firestoreService.updateUserSessionToken(
          uid: user.uid,
          token: sessionToken,
        );
      }
      state = false;
      return true;
    } catch (e) {
      state = false;
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    state = true;
    try {
      await _authService.sendPasswordResetEmail(email: email);
      state = false;
    } catch (e) {
      state = false;
      rethrow;
    }
  }

  // --- THIS IS THE FIX ---
  Future<void> signOut() async {
    // Get the current user's ID before they are signed out.
    final user = _authService.getCurrentUser();
    if (user != null) {
      // Clear the FCM and session tokens from their Firestore document.
      await _firestoreService.updateUserFcmToken(uid: user.uid, token: null);
      await _firestoreService.updateUserSessionToken(
        uid: user.uid,
        token: null,
      );
    }
    // Now, sign the user out from Firebase Auth.
    await _authService.signOut();
  }
  // --- END OF FIX ---

  Future<void> createRestaurantAndAssignOwner({
    required String restaurantName,
    required String address,
    required String phone,
    File? logoFile,
  }) async {
    final user = _authService.getCurrentUser();
    if (user == null) {
      throw Exception("User not logged in.");
    }

    String? restaurantId;
    String? logoPath;

    try {
      final newRestaurant = RestaurantModel(
        id: '',
        ownerId: user.uid,
        name: restaurantName,
        address: address,
        phone: phone,
      );
      restaurantId = await _restaurantService.createRestaurant(
        restaurant: newRestaurant,
      );

      if (logoFile != null) {
        logoPath = 'logos/$restaurantId/logo.jpg';
        final logoUrl = await _ref
            .read(storageServiceProvider)
            .uploadImage(logoPath, logoFile);
        await _restaurantService.updateLogoUrl(restaurantId, logoUrl);
      }

      await _firestoreService.updateUserRestaurantAndRole(
        uid: user.uid,
        restaurantId: restaurantId,
        role: UserRole.owner,
      );
    } catch (e) {
      if (restaurantId != null) {
        await _restaurantService.deleteRestaurant(restaurantId);
      }
      if (logoPath != null) {
        await _ref.read(storageServiceProvider).deleteImage(logoPath);
      }
      rethrow;
    }
  }
}

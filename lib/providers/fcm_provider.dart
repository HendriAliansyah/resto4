// lib/providers/fcm_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/providers/auth_providers.dart';
import 'package:resto2/services/fcm_service.dart';

// Provider for the FcmService instance
final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});

// This provider initializes the FCM service and listens for token changes.
final fcmProvider = Provider<void>((ref) {
  final fcmService = ref.watch(fcmServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final user = ref.watch(currentUserProvider).asData?.value;

  // Initialize the service (requests permissions, sets up handlers)
  fcmService.init();

  // Listen for new tokens and save them immediately.
  // This ensures the token in Firestore is always up-to-date.
  fcmService.onTokenRefresh.listen((token) {
    if (token != null && user != null) {
      firestoreService.updateUserFcmToken(uid: user.uid, token: token);
    }
  });
});

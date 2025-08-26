import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/user_model.dart';
import 'package:resto2/providers/restaurant_provider.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.read(firebaseAuthProvider)),
);

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(ref.read(firestoreProvider)),
);

final authStateChangeProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges,
);

final currentUserProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  final authState = ref.watch(authStateChangeProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  if (authState.asData?.value != null) {
    return firestoreService.watchUser(authState.asData!.value!.uid);
  }
  return Stream.value(null);
});

final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, bool>((ref) {
      return AuthController(
        ref.read(authServiceProvider),
        ref.read(firestoreServiceProvider),
        ref.read(restaurantServiceProvider),
        ref,
      );
    });

// Add this provider to hold the session token for the current device
final localSessionTokenProvider = StateProvider<String?>((ref) => null);

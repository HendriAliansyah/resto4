import 'package:firebase_database/firebase_database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/providers/auth_providers.dart';

class PresenceService {
  final FirebaseDatabase _database;
  final Ref _ref;

  PresenceService(this._database, this._ref) {
    _init();
  }

  void _init() {
    _ref.listen(currentUserProvider, (previous, next) {
      final user = next.asData?.value;
      if (user != null && user.sessionToken != null) {
        _updateUserPresence(user.uid, user.sessionToken!);
      }
    });
  }

  void _updateUserPresence(String uid, String sessionToken) {
    final userStatusDatabaseRef = _database.ref('status/$uid');

    final isOffline = {
      'state': 'offline',
      'last_changed': ServerValue.timestamp,
    };

    final isOnline = {
      'state': 'online',
      'last_changed': ServerValue.timestamp,
      'sessionToken': sessionToken,
    };

    _database.ref('.info/connected').onValue.listen((event) {
      if (event.snapshot.value == false) {
        // The onDisconnect handler will manage the token clearing.
        // No need to do anything here on the client side.
        return;
      }

      userStatusDatabaseRef.onDisconnect().set(isOffline).then((_) {
        userStatusDatabaseRef.set(isOnline);
      });
    });
  }
}

final presenceServiceProvider = Provider<PresenceService>((ref) {
  final database = FirebaseDatabase.instance;
  return PresenceService(database, ref);
});

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/table_type_model.dart';
import 'package:resto2/providers/auth_providers.dart';

// Service
class TableTypeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'tableTypes';

  Stream<List<TableType>> getTableTypesStream(String restaurantId) {
    return _db
        .collection(_collectionPath)
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TableType.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addTableType(Map<String, dynamic> data) async {
    await _db.collection(_collectionPath).add(data);
  }

  Future<void> updateTableType(String id, String name) async {
    await _db.collection(_collectionPath).doc(id).update({'name': name});
  }

  Future<void> deleteTableType(String id) async {
    await _db.collection(_collectionPath).doc(id).delete();
  }
}

// State
enum TableTypeActionStatus { initial, loading, success, error }

class TableTypeState {
  final TableTypeActionStatus status;
  final String? errorMessage;
  TableTypeState({
    this.status = TableTypeActionStatus.initial,
    this.errorMessage,
  });
}

// Providers
final tableTypeServiceProvider = Provider((ref) => TableTypeService());

final tableTypesStreamProvider = StreamProvider.autoDispose<List<TableType>>((
  ref,
) {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user?.restaurantId != null) {
    return ref
        .watch(tableTypeServiceProvider)
        .getTableTypesStream(user!.restaurantId!);
  }
  return Stream.value([]);
});

final tableTypeControllerProvider =
    StateNotifierProvider.autoDispose<TableTypeController, TableTypeState>((
      ref,
    ) {
      return TableTypeController(ref);
    });

// Controller
class TableTypeController extends StateNotifier<TableTypeState> {
  final Ref _ref;
  TableTypeController(this._ref) : super(TableTypeState());

  bool _isNameUnique(String name, String? idToExclude) {
    final types = _ref.read(tableTypesStreamProvider).asData?.value ?? [];
    return types
        .where(
          (type) =>
              type.id != idToExclude &&
              type.name.trim().toLowerCase() == name.trim().toLowerCase(),
        )
        .isEmpty;
  }

  Future<void> addTableType({required String name}) async {
    state = TableTypeState(status: TableTypeActionStatus.loading);
    if (!_isNameUnique(name, null)) {
      state = TableTypeState(
        status: TableTypeActionStatus.error,
        errorMessage: 'This table type already exists.',
      );
      return;
    }

    final restaurantId =
        _ref.read(currentUserProvider).asData?.value?.restaurantId;
    if (restaurantId == null) {
      state = TableTypeState(
        status: TableTypeActionStatus.error,
        errorMessage: 'User not in a restaurant.',
      );
      return;
    }

    try {
      await _ref.read(tableTypeServiceProvider).addTableType({
        'name': name,
        'restaurantId': restaurantId,
      });
      state = TableTypeState(status: TableTypeActionStatus.success);
    } catch (e) {
      state = TableTypeState(
        status: TableTypeActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateTableType({
    required String id,
    required String name,
  }) async {
    state = TableTypeState(status: TableTypeActionStatus.loading);
    if (!_isNameUnique(name, id)) {
      state = TableTypeState(
        status: TableTypeActionStatus.error,
        errorMessage: 'Another table type with this name already exists.',
      );
      return;
    }

    try {
      await _ref.read(tableTypeServiceProvider).updateTableType(id, name);
      state = TableTypeState(status: TableTypeActionStatus.success);
    } catch (e) {
      state = TableTypeState(
        status: TableTypeActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteTableType(String id) async {
    try {
      await _ref.read(tableTypeServiceProvider).deleteTableType(id);
    } catch (e) {
      // Error handling can be expanded here
    }
  }
}

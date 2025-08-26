import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/order_type_model.dart';
import 'package:resto2/providers/auth_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Service
class OrderTypeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'orderTypes';

  Stream<List<OrderType>> getOrderTypesStream(String restaurantId) {
    return _db
        .collection(_collectionPath)
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => OrderType.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addOrderType(Map<String, dynamic> data) async {
    await _db.collection(_collectionPath).add(data);
  }

  Future<void> updateOrderType(String id, Map<String, dynamic> data) async {
    await _db.collection(_collectionPath).doc(id).update(data);
  }

  Future<void> deleteOrderType(String id) async {
    await _db.collection(_collectionPath).doc(id).delete();
  }
}

// State
enum OrderTypeActionStatus { initial, loading, success, error }

class OrderTypeState {
  final OrderTypeActionStatus status;
  final String? errorMessage;
  OrderTypeState({
    this.status = OrderTypeActionStatus.initial,
    this.errorMessage,
  });
}

// Providers
final orderTypeServiceProvider = Provider((ref) => OrderTypeService());

final orderTypesStreamProvider = StreamProvider.autoDispose<List<OrderType>>((
  ref,
) {
  final restaurantId =
      ref.watch(currentUserProvider).asData?.value?.restaurantId;
  if (restaurantId != null) {
    return ref
        .watch(orderTypeServiceProvider)
        .getOrderTypesStream(restaurantId);
  }
  return Stream.value([]);
});

final orderTypeControllerProvider =
    StateNotifierProvider.autoDispose<OrderTypeController, OrderTypeState>((
      ref,
    ) {
      return OrderTypeController(ref);
    });

// Controller
class OrderTypeController extends StateNotifier<OrderTypeState> {
  final Ref _ref;
  OrderTypeController(this._ref) : super(OrderTypeState());

  bool _isNameUnique(String name, String? idToExclude) {
    final types = _ref.read(orderTypesStreamProvider).asData?.value ?? [];
    return types
        .where(
          (type) =>
              type.id != idToExclude &&
              type.name.trim().toLowerCase() == name.trim().toLowerCase(),
        )
        .isEmpty;
  }

  Future<void> addOrderType({
    required String name,
    required OrderTypeAccessibility accessibility,
  }) async {
    state = OrderTypeState(status: OrderTypeActionStatus.loading);
    if (!_isNameUnique(name, null)) {
      state = OrderTypeState(
        status: OrderTypeActionStatus.error,
        errorMessage: 'This order type already exists.',
      );
      return;
    }
    final restaurantId =
        _ref.read(currentUserProvider).asData?.value?.restaurantId;
    if (restaurantId == null) {
      state = OrderTypeState(
        status: OrderTypeActionStatus.error,
        errorMessage: 'User not in a restaurant.',
      );
      return;
    }
    try {
      final newOrderType = OrderType(
        id: '',
        name: name,
        accessibility: accessibility,
        restaurantId: restaurantId,
      );
      await _ref
          .read(orderTypeServiceProvider)
          .addOrderType(newOrderType.toJson());
      state = OrderTypeState(status: OrderTypeActionStatus.success);
    } catch (e) {
      state = OrderTypeState(
        status: OrderTypeActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateOrderType({
    required String id,
    required String name,
    required OrderTypeAccessibility accessibility,
  }) async {
    state = OrderTypeState(status: OrderTypeActionStatus.loading);
    if (!_isNameUnique(name, id)) {
      state = OrderTypeState(
        status: OrderTypeActionStatus.error,
        errorMessage: 'Another order type with this name already exists.',
      );
      return;
    }
    try {
      await _ref.read(orderTypeServiceProvider).updateOrderType(id, {
        'name': name,
        'accessibility': accessibility.name,
      });
      state = OrderTypeState(status: OrderTypeActionStatus.success);
    } catch (e) {
      state = OrderTypeState(
        status: OrderTypeActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteOrderType(String id) async {
    try {
      await _ref.read(orderTypeServiceProvider).deleteOrderType(id);
    } catch (e) {
      // Error handling can be expanded
    }
  }
}

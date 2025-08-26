// lib/providers/purchase_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/purchase_model.dart';
import 'package:resto2/providers/auth_providers.dart';
import 'package:resto2/providers/inventory_provider.dart';
import 'package:resto2/services/purchase_service.dart';

enum PurchaseActionStatus { initial, loading, success, error }

class PurchaseState {
  final PurchaseActionStatus status;
  final String? errorMessage;
  PurchaseState({
    this.status = PurchaseActionStatus.initial,
    this.errorMessage,
  });
}

final purchaseServiceProvider = Provider((ref) => PurchaseService());

final purchasesStreamProvider = StreamProvider<List<PurchaseModel>>((ref) {
  // THIS NOW MATCHES YOUR EXISTING CODE'S PATTERN
  final restaurantId =
      ref.watch(currentUserProvider).asData?.value?.restaurantId;
  if (restaurantId == null) {
    return Stream.value([]);
  }
  return ref
      .read(purchaseServiceProvider)
      .getRestaurantPurchasesStream(restaurantId);
});

final purchaseControllerProvider =
    StateNotifierProvider<PurchaseController, PurchaseState>(
      (ref) => PurchaseController(ref),
    );

class PurchaseController extends StateNotifier<PurchaseState> {
  final Ref _ref;
  PurchaseController(this._ref) : super(PurchaseState());

  Future<void> addPurchase({
    required String inventoryItemId,
    required double quantity,
    required double purchasePrice,
    String? notes,
  }) async {
    state = PurchaseState(status: PurchaseActionStatus.loading);
    final restaurantId =
        _ref.read(currentUserProvider).asData?.value?.restaurantId;
    if (restaurantId == null) {
      state = PurchaseState(
        status: PurchaseActionStatus.error,
        errorMessage: 'User not in a restaurant.',
      );
      return;
    }

    try {
      final newPurchase = PurchaseModel(
        id: '', // Firestore will generate it
        inventoryItemId: inventoryItemId,
        quantity: quantity,
        purchasePrice: purchasePrice,
        purchaseDate: Timestamp.now(),
        restaurantId: restaurantId,
        notes: notes,
      );

      await _ref
          .read(purchaseServiceProvider)
          .addPurchase(newPurchase.toJson());
      await _ref
          .read(inventoryControllerProvider.notifier)
          .updateStockOnPurchase(
            inventoryItemId: inventoryItemId,
            quantityAdded: quantity,
            purchasePrice: purchasePrice,
          );

      state = PurchaseState(status: PurchaseActionStatus.success);
    } catch (e) {
      state = PurchaseState(
        status: PurchaseActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// lib/providers/inventory_provider.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/inventory_item_model.dart';
import 'package:resto2/models/notification_payload.dart';
import 'package:resto2/models/stock_movement_model.dart';
import 'package:resto2/providers/auth_providers.dart';
import 'package:resto2/providers/inventory_filter_provider.dart';
import 'package:resto2/providers/notification_provider.dart';
import 'package:resto2/providers/staff_filter_provider.dart';
import 'package:resto2/providers/storage_provider.dart';
import 'package:resto2/services/inventory_service.dart';
import 'package:resto2/services/stock_movement_service.dart';

// State Enum
enum InventoryActionStatus { initial, loading, success, error }

// State Class
class InventoryState {
  final InventoryActionStatus status;
  final String? errorMessage;
  InventoryState({
    this.status = InventoryActionStatus.initial,
    this.errorMessage,
  });
}

// Service Provider
final inventoryServiceProvider = Provider((ref) => InventoryService());

final inventoryStreamProvider = StreamProvider<List<InventoryItem>>((ref) {
  // THIS NOW MATCHES YOUR EXISTING CODE'S PATTERN
  final restaurantId =
      ref.watch(currentUserProvider).asData?.value?.restaurantId;
  if (restaurantId == null) {
    return Stream.value([]);
  }
  return ref.read(inventoryServiceProvider).getInventoryStream(restaurantId);
});

// Derived Provider for filtered and sorted data
final sortedInventoryProvider = Provider.autoDispose<List<InventoryItem>>((
  ref,
) {
  final inventoryList = ref.watch(inventoryStreamProvider).asData?.value ?? [];
  final filter = ref.watch(inventoryFilterProvider);

  final filteredList =
      inventoryList.where((item) {
        return filter.searchQuery.isEmpty ||
            item.name.toLowerCase().contains(filter.searchQuery.toLowerCase());
      }).toList();

  filteredList.sort((a, b) {
    int comparison = a.name.compareTo(b.name);
    return filter.sortOrder == SortOrder.asc ? comparison : -comparison;
  });

  return filteredList;
});

// Controller Provider
final inventoryControllerProvider =
    StateNotifierProvider.autoDispose<InventoryController, InventoryState>((
      ref,
    ) {
      return InventoryController(ref);
    });

// Controller (Business Logic)
class InventoryController extends StateNotifier<InventoryState> {
  final Ref _ref;
  InventoryController(this._ref) : super(InventoryState());

  bool _isNameUnique(String name, String? idToExclude) {
    final items = _ref.read(inventoryStreamProvider).asData?.value ?? [];
    return items
        .where(
          (item) =>
              item.id != idToExclude &&
              item.name.trim().toLowerCase() == name.trim().toLowerCase(),
        )
        .isEmpty;
  }

  Future<void> addInventoryItem({
    required String name,
    required String description,
    File? imageFile,
  }) async {
    state = InventoryState(status: InventoryActionStatus.loading);
    if (!_isNameUnique(name, null)) {
      state = InventoryState(
        status: InventoryActionStatus.error,
        errorMessage: 'An item with this name already exists.',
      );
      return;
    }
    final restaurantId =
        _ref.read(currentUserProvider).asData?.value?.restaurantId;
    if (restaurantId == null) {
      state = InventoryState(
        status: InventoryActionStatus.error,
        errorMessage: 'User not in a restaurant.',
      );
      return;
    }
    try {
      final newItem = InventoryItem(
        id: '',
        name: name,
        description: description,
        restaurantId: restaurantId,
      );
      final docRef = await _ref
          .read(inventoryServiceProvider)
          .addInventoryItem(newItem.toJson());

      if (imageFile != null) {
        final imagePath = 'inventories/${docRef.id}/image.jpg';
        final imageUrl = await _ref
            .read(storageServiceProvider)
            .uploadImage(imagePath, imageFile);
        await _ref.read(inventoryServiceProvider).updateInventoryItem(
          docRef.id,
          {'imageUrl': imageUrl},
        );
      }
      state = InventoryState(status: InventoryActionStatus.success);
    } catch (e) {
      state = InventoryState(
        status: InventoryActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateInventoryItem({
    required String id,
    required String name,
    required String description,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    state = InventoryState(status: InventoryActionStatus.loading);
    if (!_isNameUnique(name, id)) {
      state = InventoryState(
        status: InventoryActionStatus.error,
        errorMessage: 'Another item with this name already exists.',
      );
      return;
    }
    try {
      String? finalImageUrl = existingImageUrl;
      if (imageFile != null) {
        final imagePath = 'inventories/$id/image.jpg';
        finalImageUrl = await _ref
            .read(storageServiceProvider)
            .uploadImage(imagePath, imageFile);
      }
      await _ref.read(inventoryServiceProvider).updateInventoryItem(id, {
        'name': name,
        'description': description,
        'imageUrl': finalImageUrl,
      });
      state = InventoryState(status: InventoryActionStatus.success);
    } catch (e) {
      state = InventoryState(
        status: InventoryActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    try {
      await _ref.read(inventoryServiceProvider).deleteInventoryItem(id);
      await _ref
          .read(storageServiceProvider)
          .deleteImage('inventories/$id/image.jpg');
    } catch (e) {
      // Error handling can be expanded
    }
  }

  Future<void> updateStockOnPurchase({
    required String inventoryItemId,
    required double quantityAdded,
    required double purchasePrice,
  }) async {
    // The call now correctly matches the service method
    final docRef = _ref
        .read(inventoryServiceProvider)
        .getInventoryItemRef(inventoryItemId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Inventory item does not exist!");
      }

      final currentItem = InventoryItem.fromFirestore(snapshot);
      final newQuantity = currentItem.quantityInStock + quantityAdded;
      final newTotalCost = currentItem.totalCost + purchasePrice;

      transaction.update(docRef, {
        'quantityInStock': newQuantity,
        'totalCost': newTotalCost,
      });
    });
  }

  Future<void> editStock({
    required InventoryItem item,
    required double newQuantity,
    required String reason,
  }) async {
    state = InventoryState(status: InventoryActionStatus.loading);
    final user = _ref.read(currentUserProvider).asData?.value;
    if (user == null || user.restaurantId == null) {
      state = InventoryState(
        status: InventoryActionStatus.error,
        errorMessage: 'User not found or not in a restaurant.',
      );
      return;
    }

    try {
      final movement = StockMovementModel(
        id: '',
        inventoryItemId: item.id,
        userId: user.uid,
        userDisplayName: user.displayName ?? 'Unknown User',
        type: StockMovementType.manualEdit,
        quantityBefore: item.quantityInStock,
        quantityAfter: newQuantity,
        reason: reason,
        createdAt: Timestamp.now(),
        restaurantId: user.restaurantId!,
      );

      // Use a transaction to ensure atomicity
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final itemRef = _ref
            .read(inventoryServiceProvider)
            .getInventoryItemRef(item.id);
        final movementRef =
            _ref.read(firestoreProvider).collection('stockMovements').doc();

        transaction.update(itemRef, {'quantityInStock': newQuantity});
        transaction.set(movementRef, movement.toJson());
      });

      // Send notification to owners and managers
      await _ref
          .read(notificationServiceProvider)
          .sendNotificationToRestaurantManagers(
            restaurantId: user.restaurantId!,
            title: 'Stock Alert: Manual Edit',
            payload: StockEditPayload(
              userDisplayName: user.displayName ?? 'Unknown User',
              itemName: item.name,
              quantityBefore: item.quantityInStock,
              quantityAfter: newQuantity,
              reason: reason,
            ),
          );

      state = InventoryState(status: InventoryActionStatus.success);
    } catch (e) {
      state = InventoryState(
        status: InventoryActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

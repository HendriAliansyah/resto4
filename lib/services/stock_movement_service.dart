// lib/services/stock_movement_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resto2/models/stock_movement_model.dart';

class StockMovementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'stockMovements';

  Future<void> addStockMovement(StockMovementModel movement) async {
    await _db.collection(_collectionPath).add(movement.toJson());
  }

  Stream<List<StockMovementModel>> getStockMovementsStream(
    String restaurantId, {
    String? inventoryItemId,
  }) {
    Query query = _db
        .collection(_collectionPath)
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true);

    if (inventoryItemId != null) {
      query = query.where('inventoryItemId', isEqualTo: inventoryItemId);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => StockMovementModel.fromFirestore(doc))
              .toList(),
    );
  }
}

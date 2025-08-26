// lib/services/inventory_service.dart (Final, Corrected Code)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resto2/models/inventory_item_model.dart';

class InventoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'inventories';

  Stream<List<InventoryItem>> getInventoryStream(String restaurantId) {
    return _db
        .collection(_collectionPath)
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => InventoryItem.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<DocumentReference> addInventoryItem(Map<String, dynamic> data) async {
    return await _db.collection(_collectionPath).add(data);
  }

  Future<void> updateInventoryItem(String id, Map<String, dynamic> data) async {
    await _db.collection(_collectionPath).doc(id).update(data);
  }

  Future<void> deleteInventoryItem(String id) async {
    await _db.collection(_collectionPath).doc(id).delete();
  }

  // THIS IS THE ONLY ADDITION
  // It gets the reference using your exact structure.
  DocumentReference getInventoryItemRef(String id) {
    return _db.collection(_collectionPath).doc(id);
  }
}

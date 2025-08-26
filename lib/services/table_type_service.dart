import 'package:cloud_firestore/cloud_firestore.dart';

class TableTypeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'tableTypes';

  Stream<List<Map<String, dynamic>>> getTableTypesStream(String restaurantId) {
    return _db
        .collection(_collectionPath)
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList(),
        );
  }

  Future<void> addTableType(Map<String, dynamic> data) async {
    await _db.collection(_collectionPath).add(data);
  }

  Future<void> updateTableType(String id, Map<String, dynamic> data) async {
    await _db.collection(_collectionPath).doc(id).update(data);
  }

  Future<void> deleteTableType(String id) async {
    await _db.collection(_collectionPath).doc(id).delete();
  }
}

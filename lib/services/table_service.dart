import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resto2/models/table_model.dart';

class TableService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'tables';

  Stream<List<TableModel>> getTablesStream(String restaurantId) {
    return _db
        .collection(_collectionPath)
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => TableModel.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<void> addTable(Map<String, dynamic> tableData) async {
    await _db.collection(_collectionPath).add(tableData);
  }

  Future<void> updateTable(
    String tableId,
    Map<String, dynamic> tableData,
  ) async {
    await _db.collection(_collectionPath).doc(tableId).update(tableData);
  }

  Future<void> deleteTable(String tableId) async {
    await _db.collection(_collectionPath).doc(tableId).delete();
  }
}

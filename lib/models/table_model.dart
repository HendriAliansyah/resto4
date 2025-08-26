import 'package:cloud_firestore/cloud_firestore.dart';

class TableModel {
  final String id;
  final String name;
  final String tableTypeId;
  final int capacity;
  final String restaurantId;

  TableModel({
    required this.id,
    required this.name,
    required this.tableTypeId,
    required this.capacity,
    required this.restaurantId,
  });

  factory TableModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TableModel(
      id: doc.id,
      name: data['name'] ?? '',
      tableTypeId: data['tableTypeId'] ?? '',
      capacity: data['capacity'] ?? 0,
      restaurantId: data['restaurantId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tableTypeId': tableTypeId,
      'capacity': capacity,
      'restaurantId': restaurantId,
    };
  }
}

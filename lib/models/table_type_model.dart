import 'package:cloud_firestore/cloud_firestore.dart';

class TableType {
  final String id;
  final String name;
  final String restaurantId;

  TableType({required this.id, required this.name, required this.restaurantId});

  factory TableType.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TableType(
      id: doc.id,
      name: data['name'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'restaurantId': restaurantId};
  }
}

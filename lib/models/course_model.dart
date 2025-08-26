import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String name;
  final String description;
  final String restaurantId;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.restaurantId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'restaurantId': restaurantId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

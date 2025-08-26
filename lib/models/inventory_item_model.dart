// lib/models/inventory_item_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String restaurantId;
  final double quantityInStock;
  final double totalCost;

  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.restaurantId,
    this.quantityInStock = 0.0,
    this.totalCost = 0.0,
  });

  double get averageCost {
    if (quantityInStock <= 0) {
      return 0.0;
    }
    return totalCost / quantityInStock;
  }

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      restaurantId: data['restaurantId'] ?? '',
      quantityInStock: (data['quantityInStock'] ?? 0.0).toDouble(),
      totalCost: (data['totalCost'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'restaurantId': restaurantId,
      'quantityInStock': quantityInStock,
      'totalCost': totalCost,
    };
  }

  // THE FIX IS HERE: By overriding equals and hashCode, we tell the dropdown
  // how to compare two InventoryItem objects. Now, it will consider them
  // equal if their IDs are the same.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

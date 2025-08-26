// lib/models/purchase_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseModel {
  final String id;
  final String inventoryItemId;
  final double quantity;
  final double purchasePrice;
  final Timestamp purchaseDate;
  final String restaurantId;
  final String? notes;

  PurchaseModel({
    required this.id,
    required this.inventoryItemId,
    required this.quantity,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.restaurantId,
    this.notes,
  });

  factory PurchaseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PurchaseModel(
      id: doc.id,
      inventoryItemId: data['inventoryItemId'] ?? '',
      quantity: (data['quantity'] ?? 0.0).toDouble(),
      purchasePrice: (data['purchasePrice'] ?? 0.0).toDouble(),
      purchaseDate: data['purchaseDate'] ?? Timestamp.now(),
      restaurantId: data['restaurantId'] ?? '',
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryItemId': inventoryItemId,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate,
      'restaurantId': restaurantId,
      'notes': notes,
    };
  }
}

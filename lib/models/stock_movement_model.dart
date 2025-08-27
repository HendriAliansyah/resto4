// lib/models/stock_movement_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum StockMovementType { manualEdit, purchase, sale, waste }

class StockMovementModel {
  final String id;
  final String inventoryItemId;
  final String userId;
  final String userDisplayName;
  final StockMovementType type;
  final double quantityBefore;
  final double quantityAfter;
  final String reason;
  final Timestamp createdAt;
  final String restaurantId;

  double get quantityChanged => quantityAfter - quantityBefore;

  StockMovementModel({
    required this.id,
    required this.inventoryItemId,
    required this.userId,
    required this.userDisplayName,
    required this.type,
    required this.quantityBefore,
    required this.quantityAfter,
    required this.reason,
    required this.createdAt,
    required this.restaurantId,
  });

  factory StockMovementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockMovementModel(
      id: doc.id,
      inventoryItemId: data['inventoryItemId'] ?? '',
      userId: data['userId'] ?? '',
      userDisplayName: data['userDisplayName'] ?? '',
      type: StockMovementType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => StockMovementType.manualEdit,
      ),
      quantityBefore: (data['quantityBefore'] ?? 0.0).toDouble(),
      quantityAfter: (data['quantityAfter'] ?? 0.0).toDouble(),
      reason: data['reason'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      restaurantId: data['restaurantId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryItemId': inventoryItemId,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'type': type.name,
      'quantityBefore': quantityBefore,
      'quantityAfter': quantityAfter,
      'reason': reason,
      'createdAt': createdAt,
      'restaurantId': restaurantId,
    };
  }
}

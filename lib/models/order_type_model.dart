import 'package:cloud_firestore/cloud_firestore.dart';

// Enum to define who can access things associated with this order type.
enum OrderTypeAccessibility { staff, all }

class OrderType {
  final String id;
  final String name;
  final OrderTypeAccessibility accessibility;
  final String restaurantId;

  OrderType({
    required this.id,
    required this.name,
    required this.accessibility,
    required this.restaurantId,
  });

  factory OrderType.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderType(
      id: doc.id,
      name: data['name'] ?? '',
      // Convert the string from Firestore back to an enum value
      accessibility: OrderTypeAccessibility.values.firstWhere(
        (e) => e.name == data['accessibility'],
        orElse: () => OrderTypeAccessibility.all, // Default to 'all'
      ),
      restaurantId: data['restaurantId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'accessibility': accessibility.name, // Store the enum as a string
      'restaurantId': restaurantId,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String? ownerId; // Ensure this links to the user
  final String name;
  final String address;
  final String phone;
  final String? logoUrl;

  RestaurantModel({
    required this.id,
    this.ownerId,
    required this.name,
    required this.address,
    required this.phone,
    this.logoUrl,
  });

  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RestaurantModel(
      id: doc.id,
      ownerId: data['ownerId'],
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      logoUrl: data['logoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'phone': phone,
      'logoUrl': logoUrl,
    };
  }
}

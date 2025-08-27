// lib/models/user_model.dart

import 'package:resto2/models/role_permission_model.dart';

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? restaurantId;
  final UserRole? role;
  final bool isDisabled;
  final String? sessionToken;
  final String? fcmToken; // Add this line

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.restaurantId,
    this.role,
    this.isDisabled = false,
    this.sessionToken,
    this.fcmToken, // Add this line
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'restaurantId': restaurantId,
      'role': role?.name,
      'isDisabled': isDisabled,
      'sessionToken': sessionToken,
      'fcmToken': fcmToken, // Add this line
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      restaurantId: json['restaurantId'],
      role:
          json['role'] != null
              ? UserRole.values.firstWhere(
                (e) => e.name == json['role'],
                orElse: () => UserRole.cashier,
              )
              : null,
      isDisabled: json['isDisabled'] ?? false,
      sessionToken: json['sessionToken'],
      fcmToken: json['fcmToken'], // Add this line
    );
  }
}

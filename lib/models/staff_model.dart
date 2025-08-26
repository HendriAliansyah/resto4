import 'package:resto2/models/role_permission_model.dart';

class Staff {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final bool isDisabled;

  Staff({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.isDisabled = false,
  });

  // THE FIX IS HERE: Add the fromJson factory constructor.
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? 'No Name',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse:
            () =>
                UserRole.cashier, // Default to cashier if role is invalid/null
      ),
      isDisabled: json['isDisabled'] ?? false,
    );
  }
}

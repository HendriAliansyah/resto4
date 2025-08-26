import 'package:cloud_firestore/cloud_firestore.dart';

enum JoinRequestStatus { pending, accepted, rejected }

class JoinRequestModel {
  final String userId;
  final String userDisplayName;
  final String userEmail;
  final JoinRequestStatus status;
  final Timestamp createdAt;

  JoinRequestModel({
    required this.userId,
    required this.userDisplayName,
    required this.userEmail,
    required this.status,
    required this.createdAt,
  });

  factory JoinRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JoinRequestModel(
      userId: data['userId'],
      userDisplayName: data['userDisplayName'],
      userEmail: data['userEmail'],
      status: JoinRequestStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => JoinRequestStatus.pending,
      ),
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userEmail': userEmail,
      'status': status.name,
      'createdAt': createdAt,
    };
  }
}

// lib/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resto2/models/notification_payload.dart';

class NotificationModel {
  final String id;
  final String title;
  final Timestamp createdAt;
  final bool isRead;
  final NotificationPayload payload; // This now holds the specific data

  NotificationModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isRead = false,
    required this.payload,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = data['type'] as String?;

    NotificationPayload payload;
    switch (type) {
      case 'joinRequest':
        payload = const JoinRequestPayload();
        break;
      case 'joinRequestResponse':
        payload = JoinRequestResponsePayload(
          wasApproved: data['wasApproved'] ?? false,
        );
        break;
      case 'stockEdit': // Added this case
        payload = StockEditPayload(
          userDisplayName: data['userDisplayName'] ?? 'Unknown User',
          itemName: data['itemName'] ?? 'Unknown Item',
          quantityBefore: (data['quantityBefore'] ?? 0.0).toDouble(),
          quantityAfter: (data['quantityAfter'] ?? 0.0).toDouble(),
          reason: data['reason'] ?? 'No reason provided',
        );
        break;
      default:
        payload = GenericPayload(message: data['body'] ?? 'No content');
    }

    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
      payload: payload,
    );
  }

  Map<String, dynamic> toJson() {
    String type;
    Map<String, dynamic> payloadData = {};

    switch (payload) {
      case GenericPayload p:
        type = 'generic';
        payloadData['body'] = p.message;
        break;
      case JoinRequestPayload _:
        type = 'joinRequest';
        break;
      case JoinRequestResponsePayload p:
        type = 'joinRequestResponse';
        payloadData['wasApproved'] = p.wasApproved;
        break;
      case StockEditPayload p: // Added this case
        type = 'stockEdit';
        payloadData['userDisplayName'] = p.userDisplayName;
        payloadData['itemName'] = p.itemName;
        payloadData['quantityBefore'] = p.quantityBefore;
        payloadData['quantityAfter'] = p.quantityAfter;
        payloadData['reason'] = p.reason;
        break;
      default:
        type = 'generic';
    }

    return {
      'title': title,
      'createdAt': createdAt,
      'isRead': isRead,
      'type': type,
      ...payloadData,
    };
  }
}

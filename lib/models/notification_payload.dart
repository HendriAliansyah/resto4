/// A base class for all notification payload types.
abstract class NotificationPayload {
  const NotificationPayload();
}

/// A payload for a simple, generic notification message.
class GenericPayload extends NotificationPayload {
  final String message;
  const GenericPayload({required this.message});
}

/// A payload for a notification related to a staff join request.
class JoinRequestPayload extends NotificationPayload {
  // We don't need extra data for this type yet, but we could add
  // things like the requestId or restaurantId in the future.
  const JoinRequestPayload();
}

/// A payload for when a user's join request is approved or rejected.
class JoinRequestResponsePayload extends NotificationPayload {
  final bool wasApproved;
  const JoinRequestResponsePayload({required this.wasApproved});
}

// functions/index.js
const {onDocumentUpdated, onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onValueWritten} = require("firebase-functions/v2/database");
const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const functions = require("firebase-functions"); // Import the logger

initializeApp();

exports.sendPushNotificationOnNewNotification = onDocumentCreated("users/{userId}/notifications/{notificationId}", async (event) => {
  const notificationData = event.data.data();
  const userId = event.params.userId;

  const userDocRef = getFirestore().collection("users").doc(userId); // Get a reference
  const userDoc = await userDocRef.get();

  if (!userDoc.exists) {
    functions.logger.warn(`User document not found for userId: ${userId}`);
    return;
  }

  const userData = userDoc.data();
  const fcmToken = userData.fcmToken;

  if (!fcmToken) {
    functions.logger.warn(`FCM token not found for user: ${userId}`);
    return;
  }

  const getNotificationBody = (notification) => {
    switch (notification.type) {
      case "joinRequest":
        return notification.body || "A new user has requested to join your restaurant.";
      case "joinRequestResponse":
        return notification.wasApproved ? "Your request to join the restaurant has been approved." : "Your request to join the restaurant has been rejected.";
      case "stockEdit":
        const quantityBefore = notification.quantityBefore || 0;
        const quantityAfter = notification.quantityAfter || 0;
        const itemName = notification.itemName || "Unknown Item";
        const reason = notification.reason || "No reason provided";
        const quantityChanged = (quantityAfter - quantityBefore).toFixed(2);
        const changePrefix = quantityAfter > quantityBefore ? "+" : "";
        return `${itemName}: ${quantityBefore.toFixed(2)} ➔ ${quantityAfter.toFixed(2)} (${changePrefix}${quantityChanged}). Reason: ${reason}`;
      default:
        return notification.body || "You have a new notification.";
    }
  };

  const payload = {
    notification: {
      title: notificationData.title,
      body: getNotificationBody(notificationData),
    },
    token: fcmToken,
    data: {
      type: notificationData.type || "generic",
    },
  };

  try {
    await getMessaging().send(payload);
    functions.logger.info(`Successfully sent push notification to user: ${userId}`);
  } catch (error) {
    functions.logger.error(`Error sending push notification to user ${userId}:`, error);

    // --- THIS IS THE FIX ---
    // If the token is invalid, remove it from the user's document.
    // The client app will automatically provide a new, valid token on its next launch.
    if (error.code === "messaging/registration-token-not-registered") {
      functions.logger.warn(`Invalid token for user ${userId}. Removing it from Firestore.`);
      await userDocRef.update({fcmToken: null});
    }
    // --- END OF FIX ---
  }
});

exports.onUserPresenceChange = onValueWritten("status/{uid}", async (event) => {
  const firestore = getFirestore();
  const uid = event.params.uid;
  const status = event.data.after.val();

  if (status && status.state === "offline") {
    const offlineToken = event.data.before.val()?.sessionToken;
    if (!offlineToken) {
      functions.logger.info(`User ${uid} went offline but had no session token.`);
      return;
    }

    const userDocRef = firestore.collection("users").doc(uid);

    try {
      await firestore.runTransaction(async (transaction) => {
        const userDoc = await transaction.get(userDocRef);
        if (!userDoc.exists) {
          return;
        }
        const currentToken = userDoc.data().sessionToken;
        if (currentToken === offlineToken) {
          transaction.update(userDocRef, {sessionToken: null});
          functions.logger.info(`Session token cleared for user: ${uid}`);
        } else {
          functions.logger.info(`Session token for user ${uid} has already been updated by a new session. No action taken.`);
        }
      });
    } catch (error) {
      functions.logger.error(`Failed to clear session token for user: ${uid}`, error);
    }
  }
});

exports.onUserStatusChange = onDocumentUpdated("users/{userId}", async (event) => {
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();
  const uid = event.params.userId;

  if (beforeData.isDisabled === afterData.isDisabled) {
    return null;
  }

  if (afterData.isDisabled === true) {
    try {
      await getAuth().revokeRefreshTokens(uid);
      await getAuth().updateUser(uid, {disabled: true});
    } catch (error) {
      functions.logger.error(`Error disabling user ${uid}`, error);
    }
  } else if (afterData.isDisabled === false) {
    functions.logger.info(`Enabling user in Firebase Auth: ${uid}`);
    try {
      await getAuth().updateUser(uid, {disabled: false});
    } catch (error) {
      functions.logger.error(`Error enabling user ${uid}`, error);
    }
  }
  return null;
});

exports.requestToJoinRestaurant = onCall(async (request) => {
  const {restaurantId} = request.data;
  const user = request.auth;

  if (!user) {
    throw new HttpsError("unauthenticated", "The function must be called while authenticated.");
  }

  const db = getFirestore();
  const restaurantRef = db.collection("restaurants").doc(restaurantId);
  const restaurantDoc = await restaurantRef.get();

  if (!restaurantDoc.exists) {
    throw new HttpsError("not-found", "No restaurant with this ID exists.", {reason: "RESTAURANT_NOT_FOUND"});
  }

  const userProfile = (await db.collection("users").doc(user.uid).get()).data();
  const joinRequest = {
    userId: user.uid,
    userDisplayName: userProfile.displayName || "No Name",
    userEmail: user.token.email,
    status: "pending",
    createdAt: new Date(),
  };
  await restaurantRef.collection("joinRequests").doc(user.uid).set(joinRequest);

  const adminQuery = await db.collection("users").where("restaurantId", "==", restaurantId).where("role", "in", ["owner", "admin"]).get();

  if (adminQuery.empty) {
    functions.logger.info("No admins found for restaurant:", restaurantId);
    return {success: true};
  }

  const batch = db.batch();
  const notificationPayload = {
    title: "New Join Request",
    type: "joinRequest",
    createdAt: new Date(),
    isRead: false,
    body: `${userProfile.displayName} has requested to join your restaurant.`,
  };

  adminQuery.docs.forEach((adminDoc) => {
    const notificationRef = adminDoc.ref.collection("notifications").doc();
    batch.set(notificationRef, notificationPayload);
  });

  await batch.commit();

  return {success: true};
});

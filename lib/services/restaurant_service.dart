import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resto2/models/join_request_model.dart';
import '../models/restaurant_model.dart';

class RestaurantService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'restaurants';

  Future<String> createRestaurant({required RestaurantModel restaurant}) async {
    final docRef = _db.collection(_collectionPath).doc();

    final newRestaurantWithId = RestaurantModel(
      id: docRef.id,
      ownerId: restaurant.ownerId,
      name: restaurant.name,
      address: restaurant.address,
      phone: restaurant.phone,
      logoUrl: restaurant.logoUrl,
    );

    await docRef.set(newRestaurantWithId.toJson());
    return docRef.id;
  }

  Future<void> deleteRestaurant(String restaurantId) async {
    await _db.collection(_collectionPath).doc(restaurantId).delete();
  }

  Stream<RestaurantModel?> getRestaurantStream(String restaurantId) {
    return _db.collection(_collectionPath).doc(restaurantId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return RestaurantModel.fromFirestore(snapshot);
      }
      return null;
    });
  }

  Future<void> saveRestaurantDetails(RestaurantModel restaurant) async {
    await _db
        .collection(_collectionPath)
        .doc(restaurant.id)
        .set(restaurant.toJson(), SetOptions(merge: true));
  }

  Future<void> updateLogoUrl(String restaurantId, String logoUrl) async {
    await _db.collection(_collectionPath).doc(restaurantId).update({
      'logoUrl': logoUrl,
    });
  }

  /// Saves a join request to a subcollection within the restaurant document.
  Future<void> submitJoinRequest({
    required String restaurantId,
    required JoinRequestModel request,
  }) async {
    // **THE FIX IS HERE:**
    // First, check if the restaurant document actually exists.
    final restaurantDoc =
        await _db.collection(_collectionPath).doc(restaurantId).get();
    if (!restaurantDoc.exists) {
      // If the document does not exist, throw an error.
      throw Exception(
        "A restaurant with this ID does not exist. Please check the ID and try again.",
      );
    }

    // If the document exists, proceed with creating the join request.
    await _db
        .collection(_collectionPath)
        .doc(restaurantId)
        .collection('joinRequests')
        .doc(request.userId) // Use user's ID to prevent duplicate requests
        .set(request.toJson());
  }
}

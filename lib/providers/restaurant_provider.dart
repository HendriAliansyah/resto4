import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/controllers/restaurant_controller.dart';
import '../models/restaurant_model.dart';
import '../services/restaurant_service.dart';
import 'auth_providers.dart';

final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  return RestaurantService();
});

// Provides the stream of restaurant data for the current user's restaurant
final restaurantStreamProvider = StreamProvider.autoDispose<RestaurantModel?>((
  ref,
) {
  // Listen to the currentUserProvider
  final appUser = ref.watch(currentUserProvider).asData?.value;

  // Use the restaurantId from the AppUser object
  if (appUser?.restaurantId != null) {
    return ref
        .watch(restaurantServiceProvider)
        .getRestaurantStream(appUser!.restaurantId!);
  }
  return Stream.value(null);
});

final restaurantControllerProvider =
    StateNotifierProvider.autoDispose<RestaurantController, bool>((ref) {
      return RestaurantController(ref);
    });

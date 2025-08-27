// lib/providers/stock_movement_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/stock_movement_model.dart';
import 'package:resto2/providers/auth_providers.dart';
import 'package:resto2/services/stock_movement_service.dart';

final stockMovementServiceProvider = Provider((ref) => StockMovementService());

final stockMovementsStreamProvider = StreamProvider.autoDispose
    .family<List<StockMovementModel>, String>((ref, inventoryItemId) {
      final restaurantId =
          ref.watch(currentUserProvider).asData?.value?.restaurantId;
      if (restaurantId == null) {
        return Stream.value([]);
      }
      return ref
          .watch(stockMovementServiceProvider)
          .getStockMovementsStream(
            restaurantId,
            inventoryItemId: inventoryItemId,
          );
    });

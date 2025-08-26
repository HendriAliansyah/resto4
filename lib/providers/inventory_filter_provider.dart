import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/providers/staff_filter_provider.dart'; // Reuse SortOrder

class InventoryFilterState {
  final String searchQuery;
  final SortOrder sortOrder;

  InventoryFilterState({this.searchQuery = '', this.sortOrder = SortOrder.asc});

  InventoryFilterState copyWith({String? searchQuery, SortOrder? sortOrder}) {
    return InventoryFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class InventoryFilterNotifier extends StateNotifier<InventoryFilterState> {
  InventoryFilterNotifier() : super(InventoryFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOrder(SortOrder order) {
    state = state.copyWith(sortOrder: order);
  }
}

final inventoryFilterProvider = StateNotifierProvider.autoDispose<
  InventoryFilterNotifier,
  InventoryFilterState
>((ref) {
  return InventoryFilterNotifier();
});

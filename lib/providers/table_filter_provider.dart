import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/providers/staff_filter_provider.dart'; // Reuse SortOrder enum

enum TableSortOption { byName, byCapacity }

class TableFilterState {
  final String? tableTypeId;
  final TableSortOption sortOption;
  final String searchQuery;
  final SortOrder sortOrder;

  TableFilterState({
    this.tableTypeId,
    this.sortOption = TableSortOption.byName,
    this.searchQuery = '',
    this.sortOrder = SortOrder.asc,
  });

  // copyWith remains for internal use, but we'll use more explicit methods in the notifier.
  TableFilterState copyWith({
    String? tableTypeId,
    TableSortOption? sortOption,
    String? searchQuery,
    SortOrder? sortOrder,
  }) {
    return TableFilterState(
      tableTypeId: tableTypeId ?? this.tableTypeId,
      sortOption: sortOption ?? this.sortOption,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class TableFilterNotifier extends StateNotifier<TableFilterState> {
  TableFilterNotifier() : super(TableFilterState());

  // THE FIX IS HERE: This method now correctly handles being set to null.
  void setTableTypeFilter(String? tableTypeId) {
    state = TableFilterState(
      tableTypeId:
          tableTypeId, // Explicitly set the new value (which can be null)
      sortOption: state.sortOption,
      searchQuery: state.searchQuery,
      sortOrder: state.sortOrder,
    );
  }

  void setSortOption(TableSortOption sortOption) {
    state = TableFilterState(
      tableTypeId: state.tableTypeId,
      sortOption: sortOption,
      searchQuery: state.searchQuery,
      sortOrder: state.sortOrder,
    );
  }

  void setSearchQuery(String query) {
    state = TableFilterState(
      tableTypeId: state.tableTypeId,
      sortOption: state.sortOption,
      searchQuery: query,
      sortOrder: state.sortOrder,
    );
  }

  void setSortOrder(SortOrder order) {
    state = TableFilterState(
      tableTypeId: state.tableTypeId,
      sortOption: state.sortOption,
      searchQuery: state.searchQuery,
      sortOrder: order,
    );
  }
}

final tableFilterProvider =
    StateNotifierProvider.autoDispose<TableFilterNotifier, TableFilterState>((
      ref,
    ) {
      return TableFilterNotifier();
    });

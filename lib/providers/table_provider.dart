import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/table_model.dart';
import 'package:resto2/providers/auth_providers.dart';
import 'package:resto2/providers/staff_filter_provider.dart';
import 'package:resto2/providers/table_filter_provider.dart';
import 'package:resto2/services/table_service.dart';

enum TableActionStatus { initial, loading, success, error }

class TableState {
  final TableActionStatus status;
  final String? errorMessage;

  TableState({this.status = TableActionStatus.initial, this.errorMessage});
}

final tableServiceProvider = Provider((ref) => TableService());

final tablesStreamProvider = StreamProvider.autoDispose<List<TableModel>>((
  ref,
) {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user?.restaurantId != null) {
    return ref.watch(tableServiceProvider).getTablesStream(user!.restaurantId!);
  }
  return Stream.value([]);
});

final sortedTablesProvider = Provider.autoDispose<List<TableModel>>((ref) {
  final tables = ref.watch(tablesStreamProvider).asData?.value ?? [];
  final filter = ref.watch(tableFilterProvider);

  // Apply search and type filters
  final filteredList =
      tables.where((table) {
        final searchMatch =
            filter.searchQuery.isEmpty ||
            table.name.toLowerCase().contains(filter.searchQuery.toLowerCase());
        final typeMatch =
            filter.tableTypeId == null ||
            table.tableTypeId == filter.tableTypeId;
        return searchMatch && typeMatch;
      }).toList();

  // Apply sorting
  filteredList.sort((a, b) {
    int comparison;
    switch (filter.sortOption) {
      case TableSortOption.byName:
        comparison = a.name.compareTo(b.name);
        break;
      case TableSortOption.byCapacity:
        comparison = a.capacity.compareTo(b.capacity);
        break;
    }
    return filter.sortOrder == SortOrder.asc ? comparison : -comparison;
  });

  return filteredList;
});

final tableControllerProvider =
    StateNotifierProvider.autoDispose<TableController, TableState>((ref) {
      return TableController(ref);
    });

class TableController extends StateNotifier<TableState> {
  final Ref _ref;
  TableController(this._ref) : super(TableState());

  bool _isNameUnique(String name, String? tableIdToExclude) {
    final tables = _ref.read(tablesStreamProvider).asData?.value ?? [];
    return tables
        .where(
          (table) =>
              table.id != tableIdToExclude &&
              table.name.trim().toLowerCase() == name.trim().toLowerCase(),
        )
        .isEmpty;
  }

  Future<void> addTable({
    required String name,
    required String tableTypeId,
    required int capacity,
  }) async {
    state = TableState(status: TableActionStatus.loading);
    if (!_isNameUnique(name, null)) {
      state = TableState(
        status: TableActionStatus.error,
        errorMessage: 'A table with this name already exists.',
      );
      return;
    }

    final restaurantId =
        _ref.read(currentUserProvider).asData?.value?.restaurantId;
    if (restaurantId == null) {
      state = TableState(
        status: TableActionStatus.error,
        errorMessage: 'User not in a restaurant.',
      );
      return;
    }

    final newTable = {
      'name': name,
      'tableTypeId': tableTypeId,
      'capacity': capacity,
      'restaurantId': restaurantId,
    };

    try {
      await _ref.read(tableServiceProvider).addTable(newTable);
      state = TableState(status: TableActionStatus.success);
    } catch (e) {
      state = TableState(
        status: TableActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateTable({
    required String tableId,
    required String name,
    required String tableTypeId,
    required int capacity,
  }) async {
    state = TableState(status: TableActionStatus.loading);
    if (!_isNameUnique(name, tableId)) {
      state = TableState(
        status: TableActionStatus.error,
        errorMessage: 'Another table with this name already exists.',
      );
      return;
    }

    final updatedTable = {
      'name': name,
      'tableTypeId': tableTypeId,
      'capacity': capacity,
    };

    try {
      await _ref.read(tableServiceProvider).updateTable(tableId, updatedTable);
      state = TableState(status: TableActionStatus.success);
    } catch (e) {
      state = TableState(
        status: TableActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteTable(String tableId) async {
    try {
      await _ref.read(tableServiceProvider).deleteTable(tableId);
    } catch (e) {
      // You can expand error handling here if needed
    }
  }
}

// lib/views/table/table_management_page.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:resto2/models/table_model.dart';
import 'package:resto2/models/table_type_model.dart';
import 'package:resto2/providers/table_filter_provider.dart';
import 'package:resto2/providers/table_provider.dart';
import 'package:resto2/providers/table_type_provider.dart';
import 'package:resto2/views/table/widgets/table_dialog.dart';
import 'package:resto2/views/widgets/app_drawer.dart';
import 'package:resto2/views/widgets/filter_expansion_tile.dart';
import 'package:resto2/views/widgets/sort_order_toggle.dart';

class TableManagementPage extends ConsumerWidget {
  const TableManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(sortedTablesProvider);
    final tableTypesAsync = ref.watch(tableTypesStreamProvider);
    final filter = ref.watch(tableFilterProvider);
    final filterNotifier = ref.read(tableFilterProvider.notifier);

    void showTableDialog({TableModel? table}) {
      showDialog(context: context, builder: (_) => TableDialog(table: table));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Table Management')),
      drawer: const AppDrawer(),
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when the user taps on an empty space
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            tableTypesAsync.when(
              data:
                  (tableTypes) => FilterExpansionTile(
                    children: [
                      TextFormField(
                        initialValue: filter.searchQuery,
                        decoration: const InputDecoration(
                          labelText: 'Search by Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged:
                            (value) => filterNotifier.setSearchQuery(value),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField2<String?>(
                        value: filter.tableTypeId,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Type',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.zero,
                        ),
                        buttonStyleData: const ButtonStyleData(
                          height: 50,
                          padding: EdgeInsets.only(right: 10),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Types'),
                          ),
                          ...tableTypes.map(
                            (type) => DropdownMenuItem(
                              value: type.id,
                              child: Text(type.name),
                            ),
                          ),
                        ],
                        onChanged:
                            (value) => filterNotifier.setTableTypeFilter(value),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField2<TableSortOption>(
                              value: filter.sortOption,
                              decoration: const InputDecoration(
                                labelText: 'Sort by',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.zero,
                              ),
                              buttonStyleData: const ButtonStyleData(
                                height: 50,
                                padding: EdgeInsets.only(right: 10),
                              ),
                              items:
                                  TableSortOption.values
                                      .map(
                                        (option) => DropdownMenuItem(
                                          value: option,
                                          child: Text(
                                            'By ${option.name.substring(2)}',
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  filterNotifier.setSortOption(value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          SortOrderToggle(
                            currentOrder: filter.sortOrder,
                            onOrderChanged: (order) {
                              filterNotifier.setSortOrder(order);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: tables.length,
                itemBuilder: (context, index) {
                  final table = tables[index];
                  final tableType = tableTypesAsync.asData?.value.firstWhere(
                    (element) => element.id == table.tableTypeId,
                    orElse:
                        () => TableType(id: '', name: 'N/A', restaurantId: ''),
                  );
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: ListTile(
                      title: Text(
                        table.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${tableType?.name} • Capacity: ${table.capacity}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => showTableDialog(table: table),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () {
                              ref
                                  .read(tableControllerProvider.notifier)
                                  .deleteTable(table.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTableDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

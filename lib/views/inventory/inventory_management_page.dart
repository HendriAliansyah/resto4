// lib/views/inventory/inventory_management_page.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/inventory_item_model.dart';
import 'package:resto2/providers/inventory_filter_provider.dart';
import 'package:resto2/providers/inventory_provider.dart';
import 'package:resto2/views/inventory/widgets/inventory_bottom_sheet.dart';
import 'package:resto2/views/widgets/app_drawer.dart';
import 'package:resto2/views/widgets/filter_expansion_tile.dart';
import 'package:resto2/views/widgets/sort_order_toggle.dart';

class InventoryManagementPage extends ConsumerWidget {
  const InventoryManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryStreamProvider);
    final sortedInventory = ref.watch(sortedInventoryProvider);
    final filterState = ref.watch(inventoryFilterProvider);

    void showItemSheet({InventoryItem? item}) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => InventoryBottomSheet(item: item),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory & Stock')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              FilterExpansionTile(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search by Name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged:
                        (value) => ref
                            .read(inventoryFilterProvider.notifier)
                            .setSearchQuery(value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Sort by Name:'),
                      const SizedBox(width: 8),
                      SortOrderToggle(
                        currentOrder: filterState.sortOrder,
                        onOrderChanged:
                            (order) => ref
                                .read(inventoryFilterProvider.notifier)
                                .setSortOrder(order),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: inventoryAsync.when(
                  data: (_) {
                    if (sortedInventory.isEmpty) {
                      return const Center(
                        child: Text('No inventory items found.'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: sortedInventory.length,
                      itemBuilder: (_, index) {
                        final item = sortedInventory[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          child: ListTile(
                            onTap: () => showItemSheet(item: item),
                            leading: SizedBox(
                              width: 56,
                              height: 56,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child:
                                    item.imageUrl != null
                                        ? Image.network(
                                          item.imageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                            Icons.inventory_2_outlined,
                                          ),
                                        ),
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Stock: ${item.quantityInStock.toStringAsFixed(2)}',
                            ),
                            trailing: Text(
                              'Avg Cost: \$${item.averageCost.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text(e.toString())),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showItemSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// lib/views/purchase/purchase_history_page.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:resto2/providers/inventory_provider.dart';
import 'package:resto2/providers/purchase_provider.dart';
import 'package:resto2/views/widgets/app_drawer.dart';
import 'package:resto2/views/widgets/loading_indicator.dart';

class PurchaseHistoryPage extends ConsumerWidget {
  const PurchaseHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchasesStreamProvider);
    final inventoryAsync = ref.watch(inventoryStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Purchase History')),
      drawer: const AppDrawer(),
      body: purchasesAsync.when(
        data: (purchases) {
          if (purchases.isEmpty) {
            return const Center(child: Text('No purchase records found.'));
          }
          return inventoryAsync.when(
            data: (inventoryItems) {
              // Create a map for easy lookup of inventory item names by their ID.
              final inventoryMap = {
                for (var item in inventoryItems) item.id: item,
              };

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: purchases.length,
                itemBuilder: (context, index) {
                  final purchase = purchases[index];
                  final item = inventoryMap[purchase.inventoryItemId];
                  final formattedDate = DateFormat.yMMMd().add_jm().format(
                    purchase.purchaseDate.toDate(),
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        item?.name ?? 'Unknown Item',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Date: $formattedDate\nNotes: ${purchase.notes ?? 'N/A'}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${purchase.purchasePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Qty: ${purchase.quantity.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const LoadingIndicator(),
            error:
                (err, stack) =>
                    Center(child: Text('Error loading inventory: $err')),
          );
        },
        loading: () => const LoadingIndicator(),
        error:
            (err, stack) =>
                Center(child: Text('Error loading purchases: $err')),
      ),
    );
  }
}

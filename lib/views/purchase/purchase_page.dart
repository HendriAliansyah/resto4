// lib/views/purchase/purchase_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/inventory_item_model.dart';
import 'package:resto2/providers/inventory_provider.dart';
import 'package:resto2/providers/purchase_provider.dart';
import 'package:resto2/utils/snackbar.dart';
import 'package:resto2/views/purchase/widgets/inventory_item_selector.dart';
import 'package:resto2/views/widgets/app_drawer.dart';
import 'package:resto2/views/widgets/loading_indicator.dart';

class ReceivingInventoryPage extends HookConsumerWidget {
  const ReceivingInventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final selectedInventoryItem = useState<InventoryItem?>(null);
    final quantityController = useTextEditingController();
    final priceController = useTextEditingController();
    final notesController = useTextEditingController();

    final inventoryAvailable =
        (ref.watch(inventoryStreamProvider).asData?.value ?? []).isNotEmpty;
    final purchaseState = ref.watch(purchaseControllerProvider);
    final isLoading = purchaseState.status == PurchaseActionStatus.loading;

    ref.listen<PurchaseState>(purchaseControllerProvider, (prev, next) {
      if (next.status == PurchaseActionStatus.success) {
        if (context.mounted) Navigator.of(context).pop();
        showSnackBar(context, 'Stock successfully updated!');
      }
      if (next.status == PurchaseActionStatus.error) {
        showSnackBar(
          context,
          next.errorMessage ?? 'An error occurred.',
          isError: true,
        );
      }
    });

    void submit() {
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState!.save();
        final quantity = double.tryParse(quantityController.text) ?? 0.0;
        final price = double.tryParse(priceController.text) ?? 0.0;

        ref
            .read(purchaseControllerProvider.notifier)
            .addPurchase(
              inventoryItemId: selectedInventoryItem.value!.id,
              quantity: quantity,
              purchasePrice: price,
              notes: notesController.text,
            );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Receiving Inventory')),
      drawer: const AppDrawer(),
      body:
          !inventoryAvailable
              ? const LoadingIndicator()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InventoryItemSelector(
                        initialValue: selectedInventoryItem.value,
                        validator:
                            (item) =>
                                item == null ? 'Please select an item.' : null,
                        onSaved: (item) => selectedInventoryItem.value = item,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity Received',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Total Cost',
                          prefixText: '\$ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (e.g., Invoice #)',
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: isLoading ? null : submit,
                        child:
                            isLoading
                                ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                )
                                : const Text('Record Stock Entry'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

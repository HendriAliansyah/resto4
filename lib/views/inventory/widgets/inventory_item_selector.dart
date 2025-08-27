// lib/views/purchase/widgets/inventory_item_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/inventory_item_model.dart';
import 'package:resto2/providers/inventory_provider.dart';

class InventoryItemSelector extends FormField<InventoryItem> {
  InventoryItemSelector({
    super.key,
    required FormFieldSetter<InventoryItem> super.onSaved,
    required FormFieldValidator<InventoryItem> super.validator,
    super.initialValue,
    ValueChanged<InventoryItem?>? onChanged, // Added this line
  }) : super(
         builder: (FormFieldState<InventoryItem> state) {
           final context = state.context;

           void showItemSelectionSheet() {
             showModalBottomSheet(
               context: context,
               isScrollControlled: true,
               useSafeArea: true,
               builder:
                   (_) => DraggableScrollableSheet(
                     expand: false,
                     initialChildSize: 0.9,
                     maxChildSize: 1.0,
                     builder: (context, scrollController) {
                       return _InventoryItemSelectionSheet(
                         scrollController: scrollController,
                         onItemSelected: (item) {
                           state.didChange(item);
                           if (onChanged != null) {
                             onChanged(item); // Added this line
                           }
                           Navigator.pop(context);
                         },
                       );
                     },
                   ),
             );
           }

           return InkWell(
             onTap: showItemSelectionSheet,
             child: InputDecorator(
               decoration: InputDecoration(
                 labelText: 'Inventory Item',
                 border: const OutlineInputBorder(),
                 errorText: state.errorText,
                 suffixIcon: const Icon(Icons.arrow_drop_down),
               ),
               child: Text(
                 state.value?.name ?? 'Select an item',
                 style:
                     state.value == null
                         ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                           color: Theme.of(context).hintColor,
                         )
                         : Theme.of(context).textTheme.bodyLarge,
               ),
             ),
           );
         },
       );
}

class _InventoryItemSelectionSheet extends HookConsumerWidget {
  final ScrollController scrollController;
  final ValueChanged<InventoryItem> onItemSelected;

  const _InventoryItemSelectionSheet({
    required this.scrollController,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useState('');
    final allItems = ref.watch(inventoryStreamProvider).asData?.value ?? [];
    final filteredItems =
        allItems
            .where(
              (item) => item.name.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
            )
            .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select Inventory Item',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => searchQuery.value = value,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('Current Stock: ${item.quantityInStock}'),
                  onTap: () => onItemSelected(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

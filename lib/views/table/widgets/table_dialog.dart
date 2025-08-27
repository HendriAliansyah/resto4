// lib/views/table/widgets/table_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:resto2/models/table_model.dart';
import 'package:resto2/providers/table_provider.dart';
import 'package:resto2/providers/table_type_provider.dart';

class TableDialog extends HookConsumerWidget {
  final TableModel? table;
  const TableDialog({super.key, this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = table != null;
    final nameController = useTextEditingController(text: table?.name);
    final capacityController = useTextEditingController(
      text: table?.capacity.toString(),
    );
    final selectedTableTypeId = useState<String?>(table?.tableTypeId);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final tableTypes = ref.watch(tableTypesStreamProvider).asData?.value ?? [];

    void submit() {
      if (formKey.currentState?.validate() ?? false) {
        final name = nameController.text;
        final capacity = int.tryParse(capacityController.text) ?? 0;
        final tableTypeId = selectedTableTypeId.value;
        if (tableTypeId == null) return;

        final controller = ref.read(tableControllerProvider.notifier);
        if (isEditing) {
          controller.updateTable(
            tableId: table!.id,
            name: name,
            tableTypeId: tableTypeId,
            capacity: capacity,
          );
        } else {
          controller.addTable(
            name: name,
            tableTypeId: tableTypeId,
            capacity: capacity,
          );
        }
        Navigator.of(context).pop();
      }
    }

    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when the user taps on an empty space
        FocusScope.of(context).unfocus();
      },
      child: AlertDialog(
        title: Text(isEditing ? 'Edit Table' : 'Add Table'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Table Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField2<String>(
                value: selectedTableTypeId.value,
                items:
                    tableTypes
                        .map(
                          (tt) => DropdownMenuItem(
                            value: tt.id,
                            child: Text(tt.name),
                          ),
                        )
                        .toList(),
                onChanged: (v) => selectedTableTypeId.value = v,
                decoration: const InputDecoration(
                  labelText: 'Table Type',
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(),
                ),
                buttonStyleData: const ButtonStyleData(
                  height: 50,
                  padding: EdgeInsets.only(right: 10),
                ),
                validator: (v) => v == null ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(onPressed: submit, child: const Text('Save')),
        ],
      ),
    );
  }
}

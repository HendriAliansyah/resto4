// lib/views/table_type/widgets/table_type_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/table_type_model.dart';
import 'package:resto2/providers/table_type_provider.dart';
import 'package:resto2/utils/snackbar.dart';

class TableTypeDialog extends HookConsumerWidget {
  final TableType? tableType;
  const TableTypeDialog({super.key, this.tableType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = tableType != null;
    final nameController = useTextEditingController(text: tableType?.name);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading =
        ref.watch(tableTypeControllerProvider).status ==
        TableTypeActionStatus.loading;

    ref.listen<TableTypeState>(tableTypeControllerProvider, (prev, next) {
      if (next.status == TableTypeActionStatus.success) {
        Navigator.of(context).pop(); // Pop the dialog itself
        showSnackBar(context, 'Table Type saved successfully!');
      }
      if (next.status == TableTypeActionStatus.error) {
        showSnackBar(
          context,
          next.errorMessage ?? 'An error occurred',
          isError: true,
        );
      }
    });

    void submit() {
      if (formKey.currentState?.validate() ?? false) {
        if (isEditing) {
          ref
              .read(tableTypeControllerProvider.notifier)
              .updateTableType(id: tableType!.id, name: nameController.text);
        } else {
          ref
              .read(tableTypeControllerProvider.notifier)
              .addTableType(name: nameController.text);
        }
      }
    }

    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when the user taps on an empty space
        FocusScope.of(context).unfocus();
      },
      child: AlertDialog(
        title: Text(isEditing ? 'Edit Table Type' : 'Add Table Type'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Type Name'),
            validator: (v) => v!.trim().isEmpty ? 'Please enter a name' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : submit,
            child:
                isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save'),
          ),
        ],
      ),
    );
  }
}

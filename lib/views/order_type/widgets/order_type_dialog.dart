// lib/views/order_type/widgets/order_type_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/order_type_model.dart';
import 'package:resto2/providers/order_type_provider.dart';
import 'package:resto2/utils/snackbar.dart';

class OrderTypeDialog extends HookConsumerWidget {
  final OrderType? orderType;
  const OrderTypeDialog({super.key, this.orderType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = orderType != null;
    final nameController = useTextEditingController(text: orderType?.name);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final accessibility = useState(
      orderType?.accessibility ?? OrderTypeAccessibility.all,
    );
    final isLoading =
        ref.watch(orderTypeControllerProvider).status ==
        OrderTypeActionStatus.loading;

    ref.listen<OrderTypeState>(orderTypeControllerProvider, (prev, next) {
      if (next.status == OrderTypeActionStatus.success) {
        if (context.mounted) Navigator.of(context).pop();
        showSnackBar(context, 'Order Type saved successfully!');
      }
      if (next.status == OrderTypeActionStatus.error) {
        showSnackBar(
          context,
          next.errorMessage ?? 'An error occurred',
          isError: true,
        );
      }
    });

    void submit() {
      if (formKey.currentState?.validate() ?? false) {
        final controller = ref.read(orderTypeControllerProvider.notifier);
        if (isEditing) {
          controller.updateOrderType(
            id: orderType!.id,
            name: nameController.text,
            accessibility: accessibility.value,
          );
        } else {
          controller.addOrderType(
            name: nameController.text,
            accessibility: accessibility.value,
          );
        }
      }
    }

    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when the user taps on an empty space
        FocusScope.of(context).unfocus();
      },
      child: AlertDialog(
        title: Text(isEditing ? 'Edit Order Type' : 'Add Order Type'),
        // THE FIX IS HERE: Constrain the width of the dialog's content.
        content: SizedBox(
          width:
              MediaQuery.of(context).size.width * 0.8, // Set a consistent width
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Order Type Name',
                    hintText: 'e.g., Dine-In, Takeaway',
                  ),
                  validator:
                      (v) => v!.trim().isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 24),
                Text(
                  'Accessibility',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<OrderTypeAccessibility>(
                  segments: const [
                    ButtonSegment(
                      value: OrderTypeAccessibility.all,
                      label: Text('All Users'),
                    ),
                    ButtonSegment(
                      value: OrderTypeAccessibility.staff,
                      label: Text('Staff Only'),
                    ),
                  ],
                  selected: {accessibility.value},
                  onSelectionChanged: (newSelection) {
                    accessibility.value = newSelection.first;
                  },
                ),
              ],
            ),
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

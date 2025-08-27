// lib/views/inventory/widgets/inventory_bottom_sheet.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resto2/models/inventory_item_model.dart';
import 'package:resto2/providers/inventory_provider.dart';
import 'package:resto2/utils/snackbar.dart';

class InventoryBottomSheet extends HookConsumerWidget {
  final InventoryItem? item;
  const InventoryBottomSheet({super.key, this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = item != null;
    final nameController = useTextEditingController(text: item?.name);
    final descriptionController = useTextEditingController(
      text: item?.description,
    );
    final localImageFile = useState<File?>(null);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final isLoading =
        ref.watch(inventoryControllerProvider).status ==
        InventoryActionStatus.loading;

    ref.listen<InventoryState>(inventoryControllerProvider, (prev, next) {
      if (next.status == InventoryActionStatus.success) {
        if (context.mounted) Navigator.of(context).pop();
        showSnackBar(context, 'Inventory item saved!');
      }
      if (next.status == InventoryActionStatus.error) {
        showSnackBar(
          context,
          next.errorMessage ?? 'An error occurred',
          isError: true,
        );
      }
    });

    void pickImage() async {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        localImageFile.value = File(image.path);
      }
    }

    void submit() {
      if (formKey.currentState?.validate() ?? false) {
        final controller = ref.read(inventoryControllerProvider.notifier);
        if (isEditing) {
          controller.updateInventoryItem(
            id: item!.id,
            name: nameController.text,
            description: descriptionController.text,
            imageFile: localImageFile.value,
            existingImageUrl: item?.imageUrl,
          );
        } else {
          controller.addInventoryItem(
            name: nameController.text,
            description: descriptionController.text,
            imageFile: localImageFile.value,
          );
        }
      }
    }

    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when the user taps on an empty space
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isEditing ? 'Edit Item' : 'Add New Item',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: pickImage,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                              image:
                                  localImageFile.value != null
                                      ? DecorationImage(
                                        image: FileImage(localImageFile.value!),
                                        fit: BoxFit.fill,
                                      )
                                      : (item?.imageUrl != null
                                          ? DecorationImage(
                                            image: NetworkImage(
                                              item!.imageUrl!,
                                            ),
                                            fit: BoxFit.fill,
                                          )
                                          : null),
                            ),
                            child:
                                localImageFile.value == null &&
                                        item?.imageUrl == null
                                    ? const Center(
                                      child: Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 48,
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (e.g., from Supplier X)',
                        ),
                        maxLines: 2,
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: isLoading ? null : submit,
                child:
                    isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

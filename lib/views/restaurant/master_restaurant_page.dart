// lib/views/restaurant/master_restaurant_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resto2/providers/auth_providers.dart';
import 'package:resto2/views/widgets/app_drawer.dart';
import '../../providers/restaurant_provider.dart';
import '../../utils/snackbar.dart';
import '../widgets/loading_indicator.dart';
import 'package:resto2/utils/constants.dart';

class MasterRestaurantPage extends HookConsumerWidget {
  const MasterRestaurantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final addressController = useTextEditingController();
    final phoneController = useTextEditingController();
    final localImageFile = useState<File?>(null);
    final phoneValidationError = useState<String?>(null);

    final isEditingLoading = ref.watch(restaurantControllerProvider);
    final isCreatingLoading = useState(false);

    final restaurantAsync = ref.watch(restaurantStreamProvider);
    final isCreating = restaurantAsync.asData?.value == null;
    final imagePicker = useMemoized(() => ImagePicker());

    useEffect(() {
      final restaurant = restaurantAsync.asData?.value;
      if (restaurant != null) {
        nameController.text = restaurant.name;
        addressController.text = restaurant.address;
        phoneController.text = restaurant.phone;
      }
      return null;
    }, [restaurantAsync]);

    useEffect(() {
      void listener() {
        if (phoneValidationError.value != null) {
          phoneValidationError.value = null;
        }
      }

      phoneController.addListener(listener);
      return () => phoneController.removeListener(listener);
    }, [phoneController]);

    void pickImage() async {
      final XFile? imageXFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (imageXFile == null) return;
      localImageFile.value = File(imageXFile.path);
    }

    void handleSaveChanges() async {
      FocusScope.of(context).unfocus();
      if (formKey.currentState?.validate() ?? false) {
        final String phoneNumberString = phoneController.text.trim();

        if (isCreating) {
          isCreatingLoading.value = true;
          try {
            await ref
                .read(authControllerProvider.notifier)
                .createRestaurantAndAssignOwner(
                  restaurantName: nameController.text,
                  address: addressController.text,
                  phone: phoneController.text,
                  logoFile: localImageFile.value,
                );
          } catch (e) {
            if (!context.mounted) return;
            showSnackBar(context, 'Error: ${e.toString()}', isError: true);
          } finally {
            if (context.mounted) {
              isCreatingLoading.value = false;
            }
          }
        } else {
          final existingLogoUrl = restaurantAsync.asData?.value?.logoUrl;
          try {
            await ref
                .read(restaurantControllerProvider.notifier)
                .saveDetails(
                  name: nameController.text,
                  address: addressController.text,
                  phone: phoneNumberString,
                  newLogoFile: localImageFile.value,
                  existingLogoUrl: existingLogoUrl,
                );
            if (!context.mounted) return;
            showSnackBar(context, 'Changes saved successfully!');
            localImageFile.value = null;
          } catch (e) {
            if (!context.mounted) return;
            showSnackBar(context, 'Error saving changes: $e', isError: true);
          }
        }
      }
    }

    final isLoading = isEditingLoading || isCreatingLoading.value;

    ImageProvider? getBackgroundImage() {
      if (localImageFile.value != null) {
        return FileImage(localImageFile.value!);
      }
      final networkUrl = restaurantAsync.asData?.value?.logoUrl;
      if (networkUrl != null) {
        return NetworkImage(networkUrl);
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isCreating
              ? UIStrings.createRestaurantTitle
              : UIStrings.manageRestaurantTitle,
        ),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Dismiss the keyboard when the user taps on an empty space
            FocusScope.of(context).unfocus();
          },
          child: restaurantAsync.when(
            data:
                (restaurant) => ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            backgroundImage: getBackgroundImage(),
                            child:
                                getBackgroundImage() == null
                                    ? const Icon(Icons.storefront, size: 50)
                                    : null,
                          ),
                          if (isLoading)
                            const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.black54,
                              child: LoadingIndicator(),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                onPressed: isLoading ? null : pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: UIStrings.restaurantName,
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter a name'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: addressController,
                            decoration: const InputDecoration(
                              labelText: UIStrings.address,
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter an address'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: UIStrings.phoneNumber,
                              hintText: UIStrings.phoneNumberHint,
                              errorText: phoneValidationError.value,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a phone number';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Please enter only numbers';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: isLoading ? null : handleSaveChanges,
                      child:
                          isLoading
                              ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(UIStrings.saving),
                                ],
                              )
                              : const Text(UIStrings.saveChanges),
                    ),
                  ],
                ),
            loading: () => const LoadingIndicator(),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ),
      ),
    );
  }
}

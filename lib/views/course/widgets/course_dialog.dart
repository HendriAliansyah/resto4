// lib/views/course/widgets/course_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/course_model.dart';
import 'package:resto2/providers/course_provider.dart';

class CourseDialog extends HookConsumerWidget {
  final Course? course;
  const CourseDialog({super.key, this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = course != null;
    final nameController = useTextEditingController(text: course?.name);
    final descriptionController = useTextEditingController(
      text: course?.description,
    );
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // THE FIX IS HERE:
    // We access the .status property of the CourseState object.
    final isLoading =
        ref.watch(courseControllerProvider).status ==
        CourseActionStatus.loading;

    void submit() {
      if (formKey.currentState?.validate() ?? false) {
        final courseController = ref.read(courseControllerProvider.notifier);
        if (isEditing) {
          courseController.updateCourse(
            courseId: course!.id,
            name: nameController.text,
            description: descriptionController.text,
          );
        } else {
          courseController.addCourse(
            name: nameController.text,
            description: descriptionController.text,
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
        title: Row(
          children: [
            Icon(
              isEditing ? Icons.edit_note : Icons.add_box_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(isEditing ? 'Edit Course' : 'Add New Course'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  hintText: 'e.g., Appetizers, Main Courses',
                ),
                validator:
                    (value) =>
                        value!.trim().isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Delicious starters to begin your meal.',
                ),
                maxLines: 2,
                validator:
                    (value) =>
                        value!.trim().isEmpty
                            ? 'Please enter a description'
                            : null,
              ),
            ],
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
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    )
                    : const Text('Save'),
          ),
        ],
      ),
    );
  }
}

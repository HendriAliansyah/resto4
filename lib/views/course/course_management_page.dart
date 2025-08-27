// lib/views/course/course_management_page.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/course_model.dart';
import 'package:resto2/providers/course_provider.dart';
import 'package:resto2/utils/snackbar.dart';
import 'package:resto2/views/course/widgets/course_dialog.dart';
import 'package:resto2/views/widgets/app_drawer.dart';
import 'package:resto2/views/widgets/loading_indicator.dart';

class CourseManagementPage extends ConsumerWidget {
  const CourseManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesStreamProvider);
    final courseController = ref.read(courseControllerProvider.notifier);

    // THE FIX: Listen to the new CourseState object
    ref.listen<CourseState>(courseControllerProvider, (previous, next) {
      if (next.status == CourseActionStatus.success) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        showSnackBar(context, 'Course saved successfully!');
      }
      // THE FIX: Extract the specific error message from the state
      if (next.status == CourseActionStatus.error) {
        showSnackBar(
          context,
          next.errorMessage ?? 'An unknown error occurred.',
          isError: true,
        );
      }
    });

    void showCourseDialog({Course? course}) {
      showDialog(
        context: context,
        builder: (dialogContext) => CourseDialog(course: course),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Course Master')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Dismiss the keyboard when the user taps on an empty space
            FocusScope.of(context).unfocus();
          },
          child: coursesAsync.when(
            data: (courses) {
              if (courses.isEmpty) {
                return const Center(
                  child: Text('No courses found. Add one to get started!'),
                );
              }
              return ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(course.name),
                      subtitle: Text(course.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => showCourseDialog(course: course),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () async {
                              await courseController.deleteCourse(course.id);
                              if (!context.mounted) return;
                              showSnackBar(context, 'Course deleted.');
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const LoadingIndicator(),
            error: (e, st) => Center(child: Text('Error: ${e.toString()}')),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCourseDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

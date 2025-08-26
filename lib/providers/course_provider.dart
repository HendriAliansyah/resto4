import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resto2/models/course_model.dart';
import 'package:resto2/providers/auth_providers.dart';
import 'package:resto2/services/course_service.dart';

// Represents the status of a course-related action
enum CourseActionStatus { initial, loading, success, error }

// Create a state class to hold status and error messages
class CourseState {
  final CourseActionStatus status;
  final String? errorMessage;

  CourseState({this.status = CourseActionStatus.initial, this.errorMessage});
}

// Provider for the CourseService
final courseServiceProvider = Provider((ref) => CourseService());

// Stream provider to get all courses for the current restaurant
final coursesStreamProvider = StreamProvider.autoDispose<List<Course>>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user?.restaurantId != null) {
    return ref
        .watch(courseServiceProvider)
        .getCoursesStream(user!.restaurantId!);
  }
  return Stream.value([]);
});

// Controller now manages the new CourseState
final courseControllerProvider =
    StateNotifierProvider.autoDispose<CourseController, CourseState>((ref) {
      return CourseController(ref);
    });

class CourseController extends StateNotifier<CourseState> {
  final Ref _ref;
  CourseController(this._ref) : super(CourseState());

  // Helper to check for unique names
  bool _isNameUnique(String name, String? courseIdToExclude) {
    final courses = _ref.read(coursesStreamProvider).asData?.value ?? [];
    return courses
        .where(
          (course) =>
              course.id != courseIdToExclude &&
              course.name.trim().toLowerCase() == name.trim().toLowerCase(),
        )
        .isEmpty;
  }

  Future<void> addCourse({
    required String name,
    required String description,
  }) async {
    state = CourseState(status: CourseActionStatus.loading);
    if (!_isNameUnique(name, null)) {
      state = CourseState(
        status: CourseActionStatus.error,
        errorMessage: 'A course with this name already exists.',
      );
      return;
    }

    final user = _ref.read(currentUserProvider).asData?.value;
    if (user?.restaurantId == null) {
      state = CourseState(
        // THE FIX IS HERE: Corrected the typo
        status: CourseActionStatus.error,
        errorMessage: 'User is not associated with a restaurant.',
      );
      return;
    }

    final newCourse = Course(
      id: '',
      name: name,
      description: description,
      restaurantId: user!.restaurantId!,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    try {
      await _ref.read(courseServiceProvider).addCourse(newCourse);
      state = CourseState(status: CourseActionStatus.success);
    } catch (e) {
      state = CourseState(
        status: CourseActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateCourse({
    required String courseId,
    required String name,
    required String description,
  }) async {
    state = CourseState(status: CourseActionStatus.loading);
    if (!_isNameUnique(name, courseId)) {
      state = CourseState(
        status: CourseActionStatus.error,
        errorMessage: 'Another course with this name already exists.',
      );
      return;
    }

    final user = _ref.read(currentUserProvider).asData?.value;
    if (user?.restaurantId == null) {
      state = CourseState(
        status: CourseActionStatus.error,
        errorMessage: 'User is not associated with a restaurant.',
      );
      return;
    }

    final updatedCourse = Course(
      id: courseId,
      name: name,
      description: description,
      restaurantId: user!.restaurantId!,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
    try {
      await _ref.read(courseServiceProvider).updateCourse(updatedCourse);
      state = CourseState(status: CourseActionStatus.success);
    } catch (e) {
      state = CourseState(
        status: CourseActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _ref.read(courseServiceProvider).deleteCourse(courseId);
    } catch (e) {
      rethrow;
    }
  }
}

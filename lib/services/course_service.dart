import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resto2/models/course_model.dart';

class CourseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'courses';

  // Get a stream of all courses for a specific restaurant
  Stream<List<Course>> getCoursesStream(String restaurantId) {
    return _db
        .collection(_collectionPath)
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList(),
        );
  }

  // Add a new course to the database
  Future<void> addCourse(Course course) async {
    await _db.collection(_collectionPath).add(course.toJson());
  }

  // Update an existing course
  Future<void> updateCourse(Course course) async {
    await _db
        .collection(_collectionPath)
        .doc(course.id)
        .update(course.toJson());
  }

  // Delete a course
  Future<void> deleteCourse(String courseId) async {
    await _db.collection(_collectionPath).doc(courseId).delete();
  }
}

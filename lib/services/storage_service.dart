import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(String path, File imageFile) async {
    try {
      final ref = _storage.ref(path);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  /// Deletes an image from a given path in Firebase Storage.
  Future<void> deleteImage(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      // It's often safe to ignore "object-not-found" errors here,
      // as it means the file we're trying to clean up never existed.
      if (e is FirebaseException && e.code != 'object-not-found') {
        debugPrint('Error deleting image: $e');
        rethrow;
      }
    }
  }
}

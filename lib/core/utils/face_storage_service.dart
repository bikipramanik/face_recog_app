import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceStorageService {
  FaceStorageService._();

  static const String _keyRegisteredFacePath = 'registered_face_path';
  static const String _faceFileName = 'registered_face.jpg';

  /// Saves the captured image file to the local application documents directory.
  /// Overwrites any existing registered face image.
  static Future<File> saveRegisteredFace(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final targetPath = '${appDir.path}/$_faceFileName';
    final targetFile = File(targetPath);

    // Evict old image from Flutter memory cache if it was already loaded
    await FileImage(targetFile).evict();

    // Copy captured image to permanent app directory
    final sourceFile = File(sourcePath);
    final savedFile = await sourceFile.copy(targetPath);

    // Save path in SharedPreferences for persistent state verification
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRegisteredFacePath, savedFile.path);
    await prefs.setInt('registered_face_updated_at', DateTime.now().millisecondsSinceEpoch);

    return savedFile;
  }

  /// Returns the registered face [File] if it exists, otherwise null.
  static Future<File?> getRegisteredFaceFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    final targetPath = '${appDir.path}/$_faceFileName';
    final file = File(targetPath);

    if (await file.exists()) {
      return file;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_keyRegisteredFacePath);
    if (savedPath != null) {
      final prefsFile = File(savedPath);
      if (await prefsFile.exists()) {
        return prefsFile;
      }
    }

    return null;
  }

  /// Checks if a face image is already saved locally.
  static Future<bool> hasRegisteredFace() async {
    final file = await getRegisteredFaceFile();
    return file != null;
  }

  /// Deletes the registered face file and clears stored preferences.
  static Future<void> deleteRegisteredFace() async {
    final file = await getRegisteredFaceFile();
    if (file != null && await file.exists()) {
      await FileImage(file).evict();
      await file.delete();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRegisteredFacePath);
    await prefs.remove('registered_face_updated_at');
  }
}

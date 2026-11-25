import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPermissionHelper {
  CameraPermissionHelper._();

  /// Checks and requests camera permission.
  /// Shows appropriate dialog if permission is permanently denied.
  static Future<bool> requestCameraPermission(BuildContext context) async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      return true;
    }

    if (!context.mounted) return false;

    if (status.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("Camera Permission Required"),
          content: const Text(
            "Camera access is needed for face recognition. Please enable it in app settings.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Camera permission is required to proceed."),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return false;
  }
}

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> handleCameraAccess(String mode) async {
  var status = await Permission.camera.status;

  if (status.isDenied) {
    status = await Permission.camera.request();
  }

  if (status.isGranted) {
    Get.snackbar(mode, "Camera permission granted. Opening camera...", snackPosition: SnackPosition.BOTTOM);
  } else if (status.isPermanentlyDenied) {
    Get.defaultDialog(
      title: "Camera Permission Required",
      middleText: "Camera access is needed for face recognition. Please enable it in app settings.",
      textConfirm: "Open Settings",
      textCancel: "Cancel",
      onConfirm: () {
        openAppSettings();
        Get.back();
      },
    );
  } else {
    Get.snackbar("Permission Denied", "Camera permission is required to proceed.", snackPosition: SnackPosition.BOTTOM);
  }
}

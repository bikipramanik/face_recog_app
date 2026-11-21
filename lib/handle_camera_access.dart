import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> handleCameraAccess(String mode) async {
  var status = await Permission.camera.status;

  if (status.isDenied) {
    status = await Permission.camera.request();
  }

  if (status.isGranted) {
    return true;
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
    return false;
  } else {
    Get.snackbar("Permission Denied", "Camera permission is required to proceed.", snackPosition: SnackPosition.BOTTOM);
    return false;
  }
}

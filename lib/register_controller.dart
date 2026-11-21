import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  CameraController? cameraController;
  List<CameraDescription> cameras = [];

  final isCameraInitialized = false.obs;
  final isFrontCamera = true.obs;
  final isCapturing = false.obs;
  final capturedImagePath = ''.obs;

  int currentCameraIndex = 0;

  @override
  void onInit() {
    super.onInit();
    initializeCameras();
  }

  Future<void> initializeCameras() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar(
          "Camera Error",
          "No cameras found on this device",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
        return;
      }

      // Default to front camera for face registration
      currentCameraIndex = cameras.indexWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
      );
      if (currentCameraIndex == -1) {
        currentCameraIndex = 0;
      }

      await startCamera(cameras[currentCameraIndex]);
    } catch (e) {
      Get.snackbar(
        "Camera Error",
        "Failed to access cameras: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  Future<void> startCamera(CameraDescription description) async {
    isCameraInitialized.value = false;
    await cameraController?.dispose();

    cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false, // Face recognition only needs video
    );

    try {
      await cameraController!.initialize();
      isFrontCamera.value =
          description.lensDirection == CameraLensDirection.front;
      isCameraInitialized.value = true;
    } catch (e) {
      Get.snackbar(
        "Camera Error",
        "Could not initialize camera: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2) {
      Get.snackbar(
        "Info",
        "Only one camera detected on this device",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    currentCameraIndex = (currentCameraIndex + 1) % cameras.length;
    await startCamera(cameras[currentCameraIndex]);
  }

  Future<void> captureAndRegisterFace() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    if (isCapturing.value) return;

    try {
      isCapturing.value = true;
      final XFile photo = await cameraController!.takePicture();
      capturedImagePath.value = photo.path;

      // Show confirmation dialog with captured face
      Get.defaultDialog(
        title: "Face Registered",
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        content: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(photo.path),
                width: 190,
                height: 230,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Face captured successfully!",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
        textConfirm: "Save & Exit",
        textCancel: "Retake",
        confirmTextColor: Colors.white,
        buttonColor: const Color.fromARGB(255, 200, 75, 225),
        cancelTextColor: Colors.black87,
        onConfirm: () {
          Get.back(); // Close dialog
          Get.back(); // Return to home screen
        },
        onCancel: () {
          capturedImagePath.value = '';
        },
      );
    } catch (e) {
      Get.snackbar(
        "Capture Error",
        "Failed to capture face: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      isCapturing.value = false;
    }
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}

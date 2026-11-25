import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

/// Status enum representing the various states of face registration.
enum RegisterStatus {
  initial,
  loading,
  ready,
  capturing,
  captured,
  failure,
}

/// State class holding all data required for the registration screen.
class RegisterState extends Equatable {
  final RegisterStatus status;
  final CameraController? cameraController;
  final List<CameraDescription> cameras;
  final int selectedCameraIndex;
  final String? capturedImagePath;
  final String? errorMessage;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.cameraController,
    this.cameras = const [],
    this.selectedCameraIndex = 0,
    this.capturedImagePath,
    this.errorMessage,
  });

  bool get isCameraInitialized =>
      status != RegisterStatus.initial &&
      status != RegisterStatus.loading &&
      cameraController != null &&
      cameraController!.value.isInitialized;

  bool get isFrontCamera {
    if (cameras.isEmpty || selectedCameraIndex >= cameras.length) {
      return true;
    }
    return cameras[selectedCameraIndex].lensDirection ==
        CameraLensDirection.front;
  }

  RegisterState copyWith({
    RegisterStatus? status,
    CameraController? cameraController,
    List<CameraDescription>? cameras,
    int? selectedCameraIndex,
    String? capturedImagePath,
    String? errorMessage,
    bool clearCapturedImage = false,
    bool clearError = false,
  }) {
    return RegisterState(
      status: status ?? this.status,
      cameraController: cameraController ?? this.cameraController,
      cameras: cameras ?? this.cameras,
      selectedCameraIndex: selectedCameraIndex ?? this.selectedCameraIndex,
      capturedImagePath:
          clearCapturedImage ? null : (capturedImagePath ?? this.capturedImagePath),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedCameraIndex,
        cameras.length,
        capturedImagePath,
        errorMessage,
      ];
}

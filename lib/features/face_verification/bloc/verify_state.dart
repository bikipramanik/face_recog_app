import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

enum VerifyStatus {
  initial,
  loading,
  ready,
  capturing,
  captured,
  failure,
}

class VerifyState extends Equatable {
  final VerifyStatus status;
  final CameraController? cameraController;
  final List<CameraDescription> cameras;
  final int selectedCameraIndex;
  final String? capturedImagePath;
  final String? errorMessage;

  const VerifyState({
    this.status = VerifyStatus.initial,
    this.cameraController,
    this.cameras = const [],
    this.selectedCameraIndex = 0,
    this.capturedImagePath,
    this.errorMessage,
  });

  bool get isCameraInitialized =>
      status != VerifyStatus.initial &&
      status != VerifyStatus.loading &&
      cameraController != null &&
      cameraController!.value.isInitialized;

  bool get isFrontCamera {
    if (cameras.isEmpty || selectedCameraIndex >= cameras.length) {
      return true;
    }
    return cameras[selectedCameraIndex].lensDirection ==
        CameraLensDirection.front;
  }

  VerifyState copyWith({
    VerifyStatus? status,
    CameraController? cameraController,
    List<CameraDescription>? cameras,
    int? selectedCameraIndex,
    String? capturedImagePath,
    String? errorMessage,
    bool clearCapturedImage = false,
    bool clearError = false,
  }) {
    return VerifyState(
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

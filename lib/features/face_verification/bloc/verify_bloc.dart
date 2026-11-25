import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'verify_event.dart';
import 'verify_state.dart';

class VerifyBloc extends Bloc<VerifyEvent, VerifyState> {
  VerifyBloc() : super(const VerifyState()) {
    on<VerifyInitializeCameras>(_onInitializeCameras);
    on<VerifySwitchCamera>(_onSwitchCamera);
    on<VerifyCaptureImage>(_onCaptureImage);
    on<VerifyResetCapture>(_onResetCapture);
  }

  Future<void> _onInitializeCameras(
    VerifyInitializeCameras event,
    Emitter<VerifyState> emit,
  ) async {
    emit(state.copyWith(
      status: VerifyStatus.loading,
      clearError: true,
    ));

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(state.copyWith(
          status: VerifyStatus.failure,
          errorMessage: "No cameras found on this device",
        ));
        return;
      }

      int defaultIndex = cameras.indexWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
      );
      if (defaultIndex == -1) {
        defaultIndex = 0;
      }

      final controller = await _createAndInitController(cameras[defaultIndex]);

      emit(state.copyWith(
        status: VerifyStatus.ready,
        cameras: cameras,
        selectedCameraIndex: defaultIndex,
        cameraController: controller,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VerifyStatus.failure,
        errorMessage: "Failed to initialize camera: $e",
      ));
    }
  }

  Future<void> _onSwitchCamera(
    VerifySwitchCamera event,
    Emitter<VerifyState> emit,
  ) async {
    if (state.cameras.length < 2) {
      emit(state.copyWith(
        status: VerifyStatus.ready,
        errorMessage: "Only one camera detected on this device",
      ));
      return;
    }

    final nextIndex = (state.selectedCameraIndex + 1) % state.cameras.length;

    emit(state.copyWith(
      status: VerifyStatus.loading,
      clearError: true,
    ));

    try {
      await state.cameraController?.dispose();
      final newController =
          await _createAndInitController(state.cameras[nextIndex]);

      emit(state.copyWith(
        status: VerifyStatus.ready,
        selectedCameraIndex: nextIndex,
        cameraController: newController,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VerifyStatus.failure,
        errorMessage: "Failed to switch camera: $e",
      ));
    }
  }

  Future<void> _onCaptureImage(
    VerifyCaptureImage event,
    Emitter<VerifyState> emit,
  ) async {
    final controller = state.cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state.status == VerifyStatus.capturing) return;

    emit(state.copyWith(
      status: VerifyStatus.capturing,
      clearError: true,
    ));

    try {
      final XFile photo = await controller.takePicture();
      emit(state.copyWith(
        status: VerifyStatus.captured,
        capturedImagePath: photo.path,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VerifyStatus.failure,
        errorMessage: "Failed to capture photo: $e",
      ));
    }
  }

  void _onResetCapture(
    VerifyResetCapture event,
    Emitter<VerifyState> emit,
  ) {
    emit(state.copyWith(
      status: VerifyStatus.ready,
      clearCapturedImage: true,
      clearError: true,
    ));
  }

  Future<CameraController> _createAndInitController(
    CameraDescription description,
  ) async {
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();
    return controller;
  }

  @override
  Future<void> close() async {
    await state.cameraController?.dispose();
    return super.close();
  }
}

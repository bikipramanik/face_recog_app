import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(const RegisterState()) {
    on<RegisterInitializeCameras>(_onInitializeCameras);
    on<RegisterSwitchCamera>(_onSwitchCamera);
    on<RegisterCaptureImage>(_onCaptureImage);
    on<RegisterResetCapture>(_onResetCapture);
  }

  Future<void> _onInitializeCameras(
    RegisterInitializeCameras event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(
      status: RegisterStatus.loading,
      clearError: true,
    ));

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: "No cameras found on this device",
        ));
        return;
      }

      // Default to front camera for face registration
      int defaultIndex = cameras.indexWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
      );
      if (defaultIndex == -1) {
        defaultIndex = 0;
      }

      final controller = await _createAndInitController(cameras[defaultIndex]);

      emit(state.copyWith(
        status: RegisterStatus.ready,
        cameras: cameras,
        selectedCameraIndex: defaultIndex,
        cameraController: controller,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: "Failed to initialize camera: $e",
      ));
    }
  }

  Future<void> _onSwitchCamera(
    RegisterSwitchCamera event,
    Emitter<RegisterState> emit,
  ) async {
    if (state.cameras.length < 2) {
      emit(state.copyWith(
        status: RegisterStatus.ready,
        errorMessage: "Only one camera detected on this device",
      ));
      return;
    }

    final nextIndex = (state.selectedCameraIndex + 1) % state.cameras.length;

    emit(state.copyWith(
      status: RegisterStatus.loading,
      clearError: true,
    ));

    try {
      await state.cameraController?.dispose();
      final newController =
          await _createAndInitController(state.cameras[nextIndex]);

      emit(state.copyWith(
        status: RegisterStatus.ready,
        selectedCameraIndex: nextIndex,
        cameraController: newController,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: "Failed to switch camera: $e",
      ));
    }
  }

  Future<void> _onCaptureImage(
    RegisterCaptureImage event,
    Emitter<RegisterState> emit,
  ) async {
    final controller = state.cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state.status == RegisterStatus.capturing) return;

    emit(state.copyWith(
      status: RegisterStatus.capturing,
      clearError: true,
    ));

    try {
      final XFile photo = await controller.takePicture();
      emit(state.copyWith(
        status: RegisterStatus.captured,
        capturedImagePath: photo.path,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: "Failed to capture photo: $e",
      ));
    }
  }

  void _onResetCapture(
    RegisterResetCapture event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      status: RegisterStatus.ready,
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

import 'package:equatable/equatable.dart';

/// Base class for all events dispatched in the Face Registration flow.
/// Events represent user interactions or system triggers.
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the registration screen opens to find and initialize cameras.
class RegisterInitializeCameras extends RegisterEvent {
  const RegisterInitializeCameras();
}

/// Dispatched when user taps the camera switch button (front <-> back).
class RegisterSwitchCamera extends RegisterEvent {
  const RegisterSwitchCamera();
}

/// Dispatched when user taps the capture button to take a face snapshot.
class RegisterCaptureImage extends RegisterEvent {
  const RegisterCaptureImage();
}

/// Dispatched when user discards the captured photo to retake.
class RegisterResetCapture extends RegisterEvent {
  const RegisterResetCapture();
}

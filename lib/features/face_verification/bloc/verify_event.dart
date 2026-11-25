import 'package:equatable/equatable.dart';

abstract class VerifyEvent extends Equatable {
  const VerifyEvent();

  @override
  List<Object?> get props => [];
}

class VerifyInitializeCameras extends VerifyEvent {
  const VerifyInitializeCameras();
}

class VerifySwitchCamera extends VerifyEvent {
  const VerifySwitchCamera();
}

class VerifyCaptureImage extends VerifyEvent {
  const VerifyCaptureImage();
}

class VerifyResetCapture extends VerifyEvent {
  const VerifyResetCapture();
}

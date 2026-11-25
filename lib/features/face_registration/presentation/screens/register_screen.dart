import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/register_bloc.dart';
import '../../bloc/register_event.dart';
import '../../bloc/register_state.dart';
import '../widgets/capture_button.dart';
import '../widgets/face_guide_overlay.dart';
import '../widgets/registration_success_dialog.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc()..add(const RegisterInitializeCameras()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  void _showCapturedDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => RegistrationSuccessDialog(
        imagePath: imagePath,
        onSaveAndExit: () {
          Navigator.of(dialogContext).pop(); // Close dialog
          Navigator.of(context).pop(); // Return to home screen
        },
        onRetake: () {
          Navigator.of(dialogContext).pop(); // Close dialog
          context.read<RegisterBloc>().add(const RegisterResetCapture());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          // Listen for errors
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: state.status == RegisterStatus.failure
                    ? AppColors.error
                    : Colors.black87,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // Listen for successful capture to open confirmation dialog
          if (state.status == RegisterStatus.captured &&
              state.capturedImagePath != null) {
            _showCapturedDialog(context, state.capturedImagePath!);
          }
        },
        builder: (context, state) {
          if (!state.isCameraInitialized || state.cameraController == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    "Opening camera...",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final cameraController = state.cameraController!;
          final cameraValue = cameraController.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Live Camera Preview
              ClipRect(
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: cameraValue.previewSize?.height ??
                          MediaQuery.of(context).size.width,
                      height: cameraValue.previewSize?.width ??
                          MediaQuery.of(context).size.height,
                      child: CameraPreview(cameraController),
                    ),
                  ),
                ),
              ),

              // 2. Oval Face Guide Overlay
              const FaceGuideOverlay(),

              // 3. Top Action Bar: Back Button, Title, and Camera Rotate Button
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black45,
                            shape: const CircleBorder(),
                          ),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),

                        // Title
                        const Text(
                          "Register Face",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),

                        // Camera Rotate / Switch Button
                        IconButton(
                          tooltip: "Switch Camera",
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black45,
                            shape: const CircleBorder(),
                          ),
                          icon: const Icon(
                            Icons.cameraswitch_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            context
                                .read<RegisterBloc>()
                                .add(const RegisterSwitchCamera());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Bottom Controls: Shutter / Capture Button
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: CaptureButton(
                      isCapturing: state.status == RegisterStatus.capturing,
                      onTap: () {
                        context
                            .read<RegisterBloc>()
                            .add(const RegisterCaptureImage());
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

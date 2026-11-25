import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:face_recog_app/core/constants/app_colors.dart';
import 'package:face_recog_app/core/utils/face_storage_service.dart';
import 'package:face_recog_app/features/face_registration/presentation/widgets/capture_button.dart';
import 'package:face_recog_app/features/face_registration/presentation/widgets/face_guide_overlay.dart';
import 'package:face_recog_app/features/face_verification/bloc/verify_bloc.dart';
import 'package:face_recog_app/features/face_verification/bloc/verify_event.dart';
import 'package:face_recog_app/features/face_verification/bloc/verify_state.dart';
import 'package:face_recog_app/features/face_verification/presentation/widgets/verification_result_dialog.dart';

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerifyBloc()..add(const VerifyInitializeCameras()),
      child: const _VerifyView(),
    );
  }
}

class _VerifyView extends StatelessWidget {
  const _VerifyView();

  Future<void> _showCapturedDialog(
    BuildContext context,
    String imagePath,
  ) async {
    final registeredFile = await FaceStorageService.getRegisteredFaceFile();

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => VerificationResultDialog(
        capturedImagePath: imagePath,
        registeredImagePath: registeredFile?.path,
        onDone: () {
          Navigator.of(dialogContext).pop(); // Close dialog
          Navigator.of(context).pop(); // Return to home screen
        },
        onRetake: () {
          Navigator.of(dialogContext).pop(); // Close dialog
          context.read<VerifyBloc>().add(const VerifyResetCapture());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<VerifyBloc, VerifyState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: state.status == VerifyStatus.failure
                    ? AppColors.error
                    : Colors.black87,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (state.status == VerifyStatus.captured &&
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
                    "Opening camera for verification...",
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

              // 3. Top Action Bar: Back Button, Title, and Camera Switch Button
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
                          "Verify Face",
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
                                .read<VerifyBloc>()
                                .add(const VerifySwitchCamera());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Bottom Controls: Shutter / Verify Button
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: CaptureButton(
                      isCapturing: state.status == VerifyStatus.capturing,
                      onTap: () {
                        context
                            .read<VerifyBloc>()
                            .add(const VerifyCaptureImage());
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

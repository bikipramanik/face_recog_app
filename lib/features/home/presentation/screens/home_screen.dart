import 'dart:io';
import 'package:flutter/material.dart';
import 'package:face_recog_app/core/constants/app_colors.dart';
import 'package:face_recog_app/core/utils/camera_permission_helper.dart';
import 'package:face_recog_app/core/utils/face_storage_service.dart';
import 'package:face_recog_app/features/face_registration/presentation/screens/register_screen.dart';
import 'package:face_recog_app/features/face_verification/presentation/screens/verify_screen.dart';
import 'package:face_recog_app/features/home/presentation/widgets/home_action_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _registeredFaceFile;
  bool _isLoading = true;
  Key _imageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadRegisteredFace();
  }

  Future<void> _loadRegisteredFace() async {
    final file = await FaceStorageService.getRegisteredFaceFile();
    if (mounted) {
      setState(() {
        _registeredFaceFile = file;
        _imageKey = UniqueKey();
        _isLoading = false;
      });
    }
  }

  Future<void> _onRegisterTap(BuildContext context) async {
    final hasFace = _registeredFaceFile != null && await _registeredFaceFile!.exists();

    if (hasFace) {
      if (!context.mounted) return;
      // Prompt user whether they want to update the existing registered image
      final shouldUpdate = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(Icons.help_outline_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                "Update Registered Image?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "A face photo is already registered. Do you want to update it with a new photo?",
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Update"),
            ),
          ],
        ),
      );

      if (shouldUpdate != true) {
        return;
      }
    }

    if (!context.mounted) return;
    await _proceedToRegistration(context);
  }

  Future<void> _proceedToRegistration(BuildContext context) async {
    final granted =
        await CameraPermissionHelper.requestCameraPermission(context);
    if (granted && context.mounted) {
      final updated = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
      if (updated == true || mounted) {
        await _loadRegisteredFace();
      }
    }
  }

  Future<void> _onVerifyTap(BuildContext context) async {
    final granted =
        await CameraPermissionHelper.requestCameraPermission(context);
    if (granted && context.mounted) {
      if (_registeredFaceFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Notice: No registered face found. You can still test the camera."),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const VerifyScreen()),
      );
    }
  }

  Widget _buildRegisteredFacePreview() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_registeredFaceFile == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.no_accounts_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            const Text(
              "No Face Registered",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Tap 'Register' below to take and save your face photo.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Registered Face",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Registered face photo with border
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13.5),
              child: Image.file(
                _registeredFaceFile!,
                key: _imageKey,
                width: 150,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Saved locally on this device",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Face Recognition App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Shows the registered photo or the un-registered prompt
              _buildRegisteredFacePreview(),
              const SizedBox(height: 20),
              // Action cards: Register and Verify
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    HomeActionCard(
                      label: "Register",
                      icon: Icons.camera_alt_rounded,
                      backgroundColor: AppColors.registerCard,
                      onTap: () => _onRegisterTap(context),
                    ),
                    HomeActionCard(
                      label: "Verify",
                      icon: Icons.face_rounded,
                      backgroundColor: AppColors.verifyCard,
                      onTap: () => _onVerifyTap(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

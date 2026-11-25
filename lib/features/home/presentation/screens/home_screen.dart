import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/camera_permission_helper.dart';
import '../../../face_registration/presentation/screens/register_screen.dart';
import '../widgets/home_action_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _onRegisterTap(BuildContext context) async {
    final granted =
        await CameraPermissionHelper.requestCameraPermission(context);
    if (granted && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    }
  }

  Future<void> _onVerifyTap(BuildContext context) async {
    final granted =
        await CameraPermissionHelper.requestCameraPermission(context);
    if (granted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Face Verification screen coming soon!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            HomeActionCard(
              label: "Register",
              icon: Icons.camera,
              backgroundColor: AppColors.registerCard,
              onTap: () => _onRegisterTap(context),
            ),
            HomeActionCard(
              label: "Verify",
              icon: Icons.face,
              backgroundColor: AppColors.verifyCard,
              onTap: () => _onVerifyTap(context),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RegistrationSuccessDialog extends StatelessWidget {
  final String imagePath;
  final VoidCallback onSaveAndExit;
  final VoidCallback onRetake;

  const RegistrationSuccessDialog({
    super.key,
    required this.imagePath,
    required this.onSaveAndExit,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Center(
        child: Text(
          "Face Registered",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(imagePath),
              width: 190,
              height: 230,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Face captured successfully!",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: onRetake,
          style: TextButton.styleFrom(
            foregroundColor: Colors.black87,
          ),
          child: const Text("Retake"),
        ),
        ElevatedButton(
          onPressed: onSaveAndExit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Save & Exit"),
        ),
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:face_recog_app/core/constants/app_colors.dart';

class VerificationResultDialog extends StatelessWidget {
  final String capturedImagePath;
  final String? registeredImagePath;
  final VoidCallback onDone;
  final VoidCallback onRetake;

  const VerificationResultDialog({
    super.key,
    required this.capturedImagePath,
    this.registeredImagePath,
    required this.onDone,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final hasRegistered =
        registeredImagePath != null && File(registeredImagePath!).existsSync();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Center(
        child: Text(
          "Face Verification",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasRegistered) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Registered",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(registeredImagePath!),
                          width: 100,
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.compare_arrows_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  Column(
                    children: [
                      const Text(
                        "Captured",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.verifyCard,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(capturedImagePath),
                          width: 100,
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(capturedImagePath),
                  width: 180,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: AppColors.success,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Face Captured for Verification",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          onPressed: onDone,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Done"),
        ),
      ],
    );
  }
}

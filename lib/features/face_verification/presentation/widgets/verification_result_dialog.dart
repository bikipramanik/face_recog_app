import 'dart:io';
import 'package:flutter/material.dart';
import 'package:face_recog_app/core/constants/app_colors.dart';
import 'package:face_recog_app/core/utils/face_recognition_service.dart';

class VerificationResultDialog extends StatelessWidget {
  final String capturedImagePath;
  final String? registeredImagePath;
  final FaceVerificationResult? result;
  final VoidCallback onDone;
  final VoidCallback onRetake;

  const VerificationResultDialog({
    super.key,
    required this.capturedImagePath,
    this.registeredImagePath,
    this.result,
    required this.onDone,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final hasRegistered =
        registeredImagePath != null && File(registeredImagePath!).existsSync();

    final isMatch = result?.isMatch ?? false;
    final isSuccess = result?.isSuccess ?? false;
    final similarity = result?.similarity ?? 0.0;
    final similarityPercent = (similarity * 100).toStringAsFixed(1);

    Color statusColor;
    IconData statusIcon;
    String statusTitle;

    if (!isSuccess) {
      statusColor = Colors.orange.shade800;
      statusIcon = Icons.warning_amber_rounded;
      statusTitle = "Recognition Warning";
    } else if (isMatch) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_rounded;
      statusTitle = "Face Match Confirmed";
    } else {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel_rounded;
      statusTitle = "Face Mismatch";
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 8),
          Text(
            statusTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: statusColor,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Side-by-side or single photo
            if (hasRegistered) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Registered Face",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(registeredImagePath!),
                            width: 105,
                            height: 135,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.compare_arrows_rounded,
                    color: statusColor,
                    size: 26,
                  ),
                  Column(
                    children: [
                      Text(
                        "Captured Now",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: statusColor,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(capturedImagePath),
                            width: 105,
                            height: 135,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(capturedImagePath),
                    width: 180,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Similarity Score Progress Bar
            if (isSuccess) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Similarity Score",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "$similarityPercent%",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: similarity,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Message note
            Text(
              result?.message ?? "Face captured successfully.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isMatch ? AppColors.success : (isSuccess ? Colors.red.shade700 : Colors.black87),
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
            backgroundColor: isMatch ? AppColors.success : AppColors.primary,
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

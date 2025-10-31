import 'package:flutter/material.dart';
import 'package:overlap/constants/app_colors.dart';

class StorageWarningBanner extends StatelessWidget {
  const StorageWarningBanner({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accentTertiary.withFraction(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accentTertiary.withFraction(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_rounded,
            color: AppColors.accentTertiary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentTertiary,
              ),
              child: const Text('재시도'),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NotificationBanner extends StatelessWidget {
  final String title;
  final String message;
  final String timeText;
  final VoidCallback onTap;

  const NotificationBanner({
    Key? key,
    required this.title,
    required this.message,
    required this.timeText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.yourTurnBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.campaign, color: AppColors.yourTurn, size: 28),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.yourTurn,
                        ),
                      ),
                      Text(
                        timeText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Align(
              alignment: Alignment.center,
              child: Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

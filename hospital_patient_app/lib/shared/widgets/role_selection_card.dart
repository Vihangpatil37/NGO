import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RoleSelectionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color baseColor;
  final VoidCallback onTap;

  const RoleSelectionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.baseColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate a very light background color from the baseColor
    final bgColor = baseColor.withOpacity(0.1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: baseColor.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(icon, color: baseColor, size: 32),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: baseColor),
          ],
        ),
      ),
    );
  }
}

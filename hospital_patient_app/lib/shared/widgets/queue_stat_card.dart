import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class QueueStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const QueueStatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF1A1A1A),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final cardColor = isDark ? AppColors.darkSurfaceCard : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final labelColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: AppColors.softShadow(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              height: 4,
              width: double.infinity,
              color: valueColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
              child: Column(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Text(
                      value,
                      key: ValueKey(value),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: valueColor,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

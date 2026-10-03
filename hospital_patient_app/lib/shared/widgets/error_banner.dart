import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ErrorBanner extends StatelessWidget {
  final String message;

  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final errorColor =
        isDark ? AppColors.darkYourTurn : const Color(0xFFD32F2F);
    final bgColor = isDark ? const Color(0xFF381414) : const Color(0xFFFFF1F2);
    final borderColor =
        isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFFCCD3);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -10 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: errorColor.withAlpha(isDark ? 25 : 15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: errorColor.withAlpha(isDark ? 40 : 25),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, color: errorColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: errorColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

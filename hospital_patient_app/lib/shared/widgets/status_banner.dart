import 'package:flutter/material.dart';
import '../../core/models/token_status.dart';
import '../../core/theme/app_theme.dart';
import 'package:hospital_patient_app/l10n/app_localizations.dart';

class StatusBanner extends StatelessWidget {
  final QueueState state;
  final int queuePosition;

  const StatusBanner({
    super.key,
    required this.state,
    required this.queuePosition,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = AppColors.isDark(context);

    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData iconData;
    String title;
    String subtitle;

    switch (state) {
      case QueueState.yourTurn:
        bgColor = isDark ? AppColors.darkYourTurnBg : const Color(0xFFFFEBEE);
        borderColor = isDark ? const Color(0xFFEF5350).withAlpha(120) : const Color(0xFFFFCDD2);
        iconColor = isDark ? AppColors.darkYourTurn : const Color(0xFFC62828);
        iconData = Icons.campaign_rounded;
        title = l10n.statusYourTurn;
        subtitle = l10n.statusYourTurnSub;
        break;
      case QueueState.almostTurn:
        bgColor = isDark ? AppColors.darkAlmostTurnBg : const Color(0xFFFFF3E0);
        borderColor = isDark ? const Color(0xFFFFA726).withAlpha(120) : const Color(0xFFFFE0B2);
        iconColor = isDark ? AppColors.darkAlmostTurn : const Color(0xFFE65100);
        iconData = Icons.alarm_on_rounded;
        title = l10n.statusAlmostTurn;
        subtitle = l10n.statusAlmostTurnSub;
        break;
      case QueueState.skipped:
        bgColor = isDark ? AppColors.darkSkippedBg : const Color(0xFFFFEBEE);
        borderColor = isDark ? const Color(0xFFE57373).withAlpha(120) : const Color(0xFFFFCDD2);
        iconColor = isDark ? AppColors.darkSkipped : const Color(0xFFD32F2F);
        iconData = Icons.error_outline_rounded;
        title = l10n.statusSkipped;
        subtitle = l10n.statusSkippedSub;
        break;
      case QueueState.completed:
        bgColor = isDark ? AppColors.darkCompletedBg : const Color(0xFFE3F2FD);
        borderColor = isDark ? const Color(0xFF64B5F6).withAlpha(120) : const Color(0xFFBBDEFB);
        iconColor = isDark ? AppColors.darkCompleted : const Color(0xFF1565C0);
        iconData = Icons.task_alt_rounded;
        title = l10n.statusCompleted;
        subtitle = l10n.statusCompletedSub;
        break;
      case QueueState.waiting:
        bgColor = isDark ? const Color(0xFF1E2835) : const Color(0xFFE8F5E9);
        borderColor = isDark ? const Color(0xFF2E3D4F) : const Color(0xFFC8E6C9);
        iconColor = isDark ? AppColors.darkWaiting : const Color(0xFF2E7D32);
        iconData = Icons.hourglass_top_rounded;
        title = l10n.statusWaiting;
        subtitle = l10n.statusWaitingSub;
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(state),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: iconColor.withAlpha(isDark ? 30 : 25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              key: ValueKey(iconData),
              tween: Tween(begin: 0.6, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(isDark ? 50 : 30),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 36, color: iconColor),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: iconColor,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/models/token_status.dart';
import 'package:hospital_patient_app/l10n/app_localizations.dart';

class StatusBanner extends StatelessWidget {
  final QueueState state;
  final int queuePosition;

  const StatusBanner({super.key, required this.state, required this.queuePosition});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData iconData;
    String title;
    String subtitle;

    switch (state) {
      case QueueState.yourTurn:
        bgColor = const Color(0xFFE8F5E9); // Light green
        borderColor = const Color(0xFFA5D6A7);
        iconColor = const Color(0xFF2E7D32);
        iconData = Icons.campaign_rounded;
        title = l10n.statusYourTurn;
        subtitle = l10n.statusYourTurnSub;
        break;
      case QueueState.almostTurn:
        bgColor = const Color(0xFFFFF8E1); // Light amber
        borderColor = const Color(0xFFFFE082);
        iconColor = const Color(0xFFF57F17);
        iconData = Icons.warning_rounded;
        title = l10n.statusAlmostTurn;
        subtitle = l10n.statusAlmostTurnSub;
        break;
      case QueueState.skipped:
        bgColor = const Color(0xFFFFF3F3); // Light red
        borderColor = const Color(0xFFFFCDCD);
        iconColor = const Color(0xFFD32F2F);
        iconData = Icons.error_outline;
        title = l10n.statusSkipped;
        subtitle = l10n.statusSkippedSub;
        break;
      case QueueState.completed:
        bgColor = const Color(0xFFE3F2FD); // Light blue
        borderColor = const Color(0xFF90CAF9);
        iconColor = const Color(0xFF1565C0);
        iconData = Icons.check_circle_outline;
        title = l10n.statusCompleted;
        subtitle = l10n.statusCompletedSub;
        break;
      case QueueState.waiting:
        bgColor = Colors.white;
        borderColor = const Color(0xFFEEEEEE);
        iconColor = const Color(0xFF757575);
        iconData = Icons.hourglass_bottom;
        title = l10n.statusWaiting;
        subtitle = l10n.statusWaitingSub;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: iconColor.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(iconData, size: 48, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: iconColor.withAlpha(200), // Slightly faded for subtitle
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/app_router.dart';
import '../../shared/widgets/primary_button.dart';
import 'package:hospital_patient_app/l10n/app_localizations.dart';
import '../../core/services/local_notification_service.dart';

class TokenConfirmedScreen extends StatefulWidget {
  final int tokenNumber;
  final String caseNumber;
  final int queuePosition;
  final String tokenId;
  final String patientName;

  const TokenConfirmedScreen({
    super.key,
    required this.tokenNumber,
    required this.caseNumber,
    required this.queuePosition,
    required this.tokenId,
    required this.patientName,
  });

  @override
  State<TokenConfirmedScreen> createState() => _TokenConfirmedScreenState();
}

class _TokenConfirmedScreenState extends State<TokenConfirmedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalNotificationService().showNotification(
        title: '✅ Registration Confirmed / નોંધણી સફળ',
        body: 'Your OPD Token is #${widget.tokenNumber}. Please keep this token with you.',
        priority: 'normal',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent going back to form
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // Green success badge
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.waitingBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.waiting,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.tokenConfirmed,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.caseIdDisplay(widget.caseNumber, widget.patientName),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 36),

                // Large token display container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 2.0),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.yourTokenNumber.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.tokenNumber.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: -2.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.queuePosition} ${AppLocalizations.of(context)!.peopleBeforeYou}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.pleaseWaitForTurn,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Dominant CTA
                PrimaryButton(
                  text: AppLocalizations.of(context)!.viewMyToken,
                  icon: Icons.confirmation_number,
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRouter.myToken,
                      arguments: {'tokenId': widget.tokenId},
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

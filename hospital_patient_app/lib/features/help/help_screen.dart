import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/gradient_header.dart';
import 'package:hospital_patient_app/l10n/app_localizations.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = AppColors.isDark(context);
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Column(
        children: [
          GradientHeader(
            title: l10n.help,
            subtitle: l10n.helpDesc,
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hospital details card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: AppDecorations.glassCard(context, radius: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withAlpha(isDark ? 40 : 25),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.local_hospital_rounded,
                                color: primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppConstants.hospitalName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : const Color(0xFF64748B),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppConstants.hospitalAddress,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : AppColors.primaryLight.withAlpha(120),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor.withAlpha(isDark ? 60 : 40),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone_in_talk_rounded,
                                color: isDark
                                    ? AppColors.darkWaiting
                                    : AppColors.waiting,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.hospitalHelpline,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    AppConstants.hospitalHelpline,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    l10n.faqTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _ExpandableFaqTile(
                    icon: Icons.confirmation_number_outlined,
                    question: l10n.faqTokenQuestion,
                    answer: l10n.faqTokenAnswer,
                    initiallyExpanded: true,
                  ),
                  const SizedBox(height: 12),

                  _ExpandableFaqTile(
                    icon: Icons.schedule_rounded,
                    question: l10n.faqMissedQuestion,
                    answer: l10n.faqMissedAnswer,
                  ),
                  const SizedBox(height: 12),

                  _ExpandableFaqTile(
                    icon: Icons.stay_current_portrait_rounded,
                    question: l10n.faqAppOpenQuestion,
                    answer: l10n.faqAppOpenAnswer,
                  ),
                  const SizedBox(height: 12),

                  _ExpandableFaqTile(
                    icon: Icons.badge_outlined,
                    question: l10n.faqCaseIdQuestion,
                    answer: l10n.faqCaseIdAnswer,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableFaqTile extends StatelessWidget {
  final IconData icon;
  final String question;
  final String answer;
  final bool initiallyExpanded;

  const _ExpandableFaqTile({
    required this.icon,
    required this.question,
    required this.answer,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Container(
      decoration: AppDecorations.glassCard(context, radius: 18),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(isDark ? 35 : 20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          title: Text(
            question,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          iconColor: primaryColor,
          collapsedIconColor:
              isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
          childrenPadding:
              const EdgeInsets.fromLTRB(18, 0, 18, 16),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161E28)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFEDF2F7),
                ),
              ),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : const Color(0xFF475569),
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

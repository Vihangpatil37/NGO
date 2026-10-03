import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/app_router.dart';
import '../../shared/widgets/primary_button.dart';
import 'package:hospital_patient_app/l10n/app_localizations.dart';

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

class _TokenConfirmedScreenState extends State<TokenConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = AppColors.isDark(context);
    final waitingColor =
        isDark ? AppColors.darkWaiting : AppColors.waiting;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.primary;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.getBackground(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 1),

                // Animated celebration checkmark
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: waitingColor.withAlpha(isDark ? 45 : 30),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: waitingColor.withAlpha(isDark ? 60 : 40),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: waitingColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        l10n.tokenConfirmed,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.caseIdDisplay(widget.caseNumber, widget.patientName),
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Central Token Card with count-up animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: primaryColor.withAlpha(isDark ? 100 : 70),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withAlpha(isDark ? 40 : 25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(isDark ? 30 : 20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'REGISTRATION SUCCESSFUL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Icon(
                          Icons.check_circle_rounded,
                          size: 80,
                          color: primaryColor,
                        ),
                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : AppColors.accentLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (isDark
                                      ? AppColors.darkAccent
                                      : AppColors.accent)
                                  .withAlpha(60),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_alt_outlined,
                                size: 16,
                                color: isDark
                                    ? AppColors.darkAccent
                                    : AppColors.accent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.queuePosition} ${l10n.peopleBeforeYou}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkAccent
                                      : AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    l10n.pleaseWaitForTurn,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(flex: 2),

                // Dominant CTA
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: PrimaryButton(
                    text: 'View Queue Status',
                    icon: Icons.people_alt_rounded,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.myToken,
                        arguments: {'tokenId': widget.tokenId},
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

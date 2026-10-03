import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/app_router.dart';
import '../../shared/widgets/gradient_header.dart';
import '../../shared/widgets/error_banner.dart';
import 'doctor_provider.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  State<DoctorAvailabilityScreen> createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DoctorProvider>(context, listen: false).loadAvailability();
    });
  }

  Future<void> _handleSubmit(String status) async {
    final provider = Provider.of<DoctorProvider>(context, listen: false);
    final success = await provider.submitAvailability(status);

    if (success && mounted) {
      final message = status == 'coming'
          ? 'You are marked as coming today.'
          : 'You are marked as not coming today.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor:
              status == 'coming' ? AppColors.waiting : AppColors.yourTurn,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final provider = Provider.of<DoctorProvider>(context, listen: false);
    await provider.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.welcome,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Column(
        children: [
          GradientHeader(
            title: 'OPD Schedule',
            subtitle: 'Doctor Availability Management',
            showBackButton: true,
            onBack: _handleLogout,
            actions: [
              Material(
                color: Colors.white.withAlpha(35),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded,
                      color: Colors.white, size: 20),
                  tooltip: 'Logout',
                  onPressed: _handleLogout,
                ),
              ),
            ],
          ),
          Expanded(
            child: Consumer<DoctorProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor Profile Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration:
                            AppDecorations.glassCard(context, radius: 22),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: primaryColor.withAlpha(isDark ? 40 : 25),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person_pin_rounded,
                                  size: 32,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    provider.doctorName ?? 'Doctor',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  if (provider.specialization != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      provider.specialization!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Today's OPD card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF162533)
                              : AppColors.primaryLight.withAlpha(140),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryColor.withAlpha(isDark ? 60 : 40),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withAlpha(isDark ? 40 : 25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                color: primaryColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "TODAY'S OPD DATE",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  provider.windowDate ?? '--',
                                  style: TextStyle(
                                    fontSize: 17,
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
                      const SizedBox(height: 24),

                      // Current status banner (if already responded)
                      if (provider.availabilityStatus != null) ...[
                        _DoctorStatusBanner(status: provider.availabilityStatus!),
                        const SizedBox(height: 20),
                        Text(
                          'Update your status for today:',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ] else ...[
                        Text(
                          'Are you attending today\'s OPD?',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Error banner
                      if (provider.error != null) ...[
                        ErrorBanner(message: provider.error!),
                        const SizedBox(height: 18),
                      ],

                      // YES button
                      _DoctorAvailabilityOption(
                        label: "YES, I'M ATTENDING",
                        subtitle: 'Patients can be assigned to you today',
                        icon: Icons.check_circle_rounded,
                        color: isDark
                            ? AppColors.darkWaiting
                            : AppColors.waiting,
                        bgColor: isDark
                            ? AppColors.darkWaitingBg
                            : AppColors.waitingBg,
                        isSelected: provider.availabilityStatus == 'coming',
                        isDisabled: provider.isSubmitting,
                        onTap: () => _handleSubmit('coming'),
                      ),
                      const SizedBox(height: 14),

                      // NO button
                      _DoctorAvailabilityOption(
                        label: "NO, NOT ATTENDING",
                        subtitle: 'No tokens will be routed to your queue',
                        icon: Icons.cancel_rounded,
                        color: isDark
                            ? AppColors.darkYourTurn
                            : AppColors.yourTurn,
                        bgColor: isDark
                            ? AppColors.darkYourTurnBg
                            : AppColors.yourTurnBg,
                        isSelected:
                            provider.availabilityStatus == 'not_coming',
                        isDisabled: provider.isSubmitting,
                        onTap: () => _handleSubmit('not_coming'),
                      ),

                      if (provider.isSubmitting) ...[
                        const SizedBox(height: 24),
                        const Center(child: CircularProgressIndicator()),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorStatusBanner extends StatelessWidget {
  final String status;
  const _DoctorStatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final isComing = status == 'coming';
    final isDark = AppColors.isDark(context);
    final statusColor = isComing
        ? (isDark ? AppColors.darkWaiting : AppColors.waiting)
        : (isDark ? AppColors.darkYourTurn : AppColors.yourTurn);
    final bgColor = isComing
        ? (isDark ? AppColors.darkWaitingBg : AppColors.waitingBg)
        : (isDark ? AppColors.darkYourTurnBg : AppColors.yourTurnBg);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withAlpha(120),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isComing ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: statusColor,
            size: 32,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT RESPONSE',
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isComing
                      ? 'Marked as Attending Today'
                      : 'Marked as Not Attending Today',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorAvailabilityOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _DoctorAvailabilityOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? bgColor
                : (isDark ? AppColors.darkSurfaceCard : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
              width: isSelected ? 2.2 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withAlpha(isDark ? 40 : 30),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : AppColors.softShadow(context),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(isDark ? 40 : 25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDisabled
                            ? (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary)
                            : (isSelected
                                ? color
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

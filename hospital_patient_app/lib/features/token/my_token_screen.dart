import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/status_banner.dart';
import '../../shared/widgets/queue_stat_card.dart';
import '../../shared/widgets/gradient_header.dart';
import '../../shared/widgets/pulse_dot.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../../core/navigation/app_router.dart';
import 'token_provider.dart';
import 'package:hospital_patient_app/l10n/app_localizations.dart';

class MyTokenScreen extends StatefulWidget {
  final String tokenId;

  const MyTokenScreen({super.key, required this.tokenId});

  @override
  State<MyTokenScreen> createState() => _MyTokenScreenState();
}

class _MyTokenScreenState extends State<MyTokenScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TokenProvider>().fetchStatus(widget.tokenId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = AppColors.isDark(context);

    return Consumer<TokenProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.getBackground(context),
            body: Column(
              children: [
                GradientHeader(
                  title: l10n.myToken,
                  showBackButton: true,
                  onBack: () => _handleBack(context),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ShimmerLoading(
                      child: Column(
                        children: [
                          const ShimmerBox(height: 110, borderRadius: 20),
                          const SizedBox(height: 20),
                          const ShimmerBox(height: 180, borderRadius: 28),
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              Expanded(child: ShimmerBox(height: 100, borderRadius: 20)),
                              SizedBox(width: 14),
                              Expanded(child: ShimmerBox(height: 100, borderRadius: 20)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const ShimmerBox(width: 180, height: 24, borderRadius: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.error != null) {
          final errorText = (provider.error == 'error_load_token' ||
                  provider.error == 'Unable to load token details.')
              ? l10n.errorLoadToken
              : provider.error!;

          return Scaffold(
            backgroundColor: AppColors.getBackground(context),
            body: Column(
              children: [
                GradientHeader(
                  title: l10n.myToken,
                  showBackButton: true,
                  onBack: () => _handleBack(context),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? AppColors.darkYourTurn
                                      : AppColors.yourTurn)
                                  .withAlpha(isDark ? 40 : 25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.wifi_off_rounded,
                              size: 56,
                              color: isDark
                                  ? AppColors.darkYourTurn
                                  : AppColors.yourTurn,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            errorText,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(180, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              provider.fetchStatus(widget.tokenId);
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(l10n.tryAgain),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.status == null) {
          return Scaffold(
            backgroundColor: AppColors.getBackground(context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final status = provider.status!;
        final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

        return Scaffold(
          backgroundColor: AppColors.getBackground(context),
          body: Column(
            children: [
              GradientHeader(
                title: l10n.myToken,
                subtitle: status.patientName.isNotEmpty
                    ? '${status.patientName} (${status.caseNumber.isNotEmpty ? status.caseNumber : l10n.patientLabel})'
                    : null,
                showBackButton: true,
                onBack: () => _handleBack(context),
                actions: [
                  Material(
                    color: Colors.white.withAlpha(35),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      icon: const Icon(Icons.help_outline_rounded,
                          color: Colors.white, size: 22),
                      tooltip: l10n.help,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.help);
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: RefreshIndicator(
                  color: primaryColor,
                  backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                  onRefresh: () => provider.fetchStatus(widget.tokenId),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        StatusBanner(
                          state: status.queueState,
                          queuePosition: status.queuePosition,
                        ),
                        const SizedBox(height: 18),

                        // Central Token Number Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 30, horizontal: 20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceCard
                                : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            boxShadow: AppColors.softShadow(context),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: (isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.primary)
                                      .withAlpha(isDark ? 35 : 20),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'ACTIVE QUEUE STATUS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                Icons.access_time_filled_rounded,
                                size: 80,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),



                        // Realtime Sync Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PulseDot(
                                color: isDark
                                    ? AppColors.darkWaiting
                                    : AppColors.waiting,
                                size: 9,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l10n.liveUpdatesActive,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Clear session button
                        TextButton.icon(
                          onPressed: () =>
                              _confirmExitSession(context, provider),
                          icon: Icon(
                            Icons.exit_to_app_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          label: Text(
                            l10n.clearTokenPrompt,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.welcome, (route) => false);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRouter.welcome);
    }
  }

  void _confirmExitSession(BuildContext context, TokenProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = AppColors.isDark(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          l10n.exitQueueTitle,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Text(
          l10n.exitQueueMessage,
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkYourTurn
                  : AppColors.yourTurn,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final dialogNavigator = Navigator.of(ctx);
              await provider.clearSession();
              dialogNavigator.pop();
              navigator.pushNamedAndRemoveUntil(
                  AppRouter.welcome, (route) => false);
            },
            child: Text(l10n.exit),
          ),
        ],
      ),
    );
  }
}

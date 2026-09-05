import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/status_banner.dart';
import '../../shared/widgets/queue_stat_card.dart';
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
    return Consumer<TokenProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.loadingConnecting,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.error != null) {
          final errorText = (provider.error == 'error_load_token' || provider.error == 'Unable to load token details.')
              ? AppLocalizations.of(context)!.errorLoadToken
              : provider.error!;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.myToken),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.welcome, (route) => false);
                  } else {
                    Navigator.of(context).pushReplacementNamed(AppRouter.welcome);
                  }
                },
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.yourTurn),
                    const SizedBox(height: 16),
                    Text(
                      errorText,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        provider.fetchStatus(widget.tokenId);
                      },
                      child: Text(AppLocalizations.of(context)!.tryAgain),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final status = provider.status!;
        
        // When it is your turn, show alert logic. This should ideally be outside build,
        // but for simplicity we keep it attached to the UI response here or in provider.

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.myToken),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.welcome, (route) => false);
                } else {
                  Navigator.of(context).pushReplacementNamed(AppRouter.welcome);
                }
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: AppColors.textSecondary),
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.help);
                },
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchStatus(widget.tokenId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (status.patientName.isNotEmpty) ...[
                      Text(
                        '${status.patientName} (${status.caseNumber.isNotEmpty ? status.caseNumber : AppLocalizations.of(context)!.patientLabel})',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    StatusBanner(
                      state: status.queueState,
                      queuePosition: status.queuePosition,
                    ),
                    const SizedBox(height: 20),

                    // Central Token Number Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
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
                          const SizedBox(height: 8),
                          Text(
                            status.tokenNumber.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: 84,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -3.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Queue Details Grid
                    Row(
                      children: [
                        Expanded(
                          child: QueueStatCard(
                            label: AppLocalizations.of(context)!.currentlyServing,
                            value: status.currentlyServing != null
                                ? status.currentlyServing.toString().padLeft(2, '0')
                                : '--',
                            valueColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: QueueStatCard(
                            label: AppLocalizations.of(context)!.peopleBeforeYou,
                            value: status.status == 'called' ? '0' : status.queuePosition.toString(),
                            valueColor: status.queuePosition <= 2 ? AppColors.almostTurn : AppColors.waiting,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Realtime Sync Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.waiting,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.liveUpdatesActive,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // Clear session button
                    TextButton(
                      onPressed: () => _confirmExitSession(context, provider),
                      child: Text(
                        AppLocalizations.of(context)!.clearTokenPrompt,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  void _confirmExitSession(BuildContext context, TokenProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.exitQueueTitle),
        content: Text(
          AppLocalizations.of(context)!.exitQueueMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.yourTurn),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final dialogNavigator = Navigator.of(ctx);
              await provider.clearSession();
              dialogNavigator.pop();
              navigator.pushNamedAndRemoveUntil(AppRouter.welcome, (route) => false);
            },
            child: Text(AppLocalizations.of(context)!.exit),
          ),
        ],
      ),
    );
  }
}

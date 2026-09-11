import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/app_router.dart';
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
    // Load availability after frame renders
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
          content: Text(message),
          backgroundColor:
              status == 'coming' ? AppColors.waiting : AppColors.yourTurn,
          behavior: SnackBarBehavior.floating,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Doctor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleLogout,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<DoctorProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome,',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    provider.doctorName ?? 'Doctor',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (provider.specialization != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      provider.specialization!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Today's OPD card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withAlpha(50)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's OPD",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.windowDate ?? '--',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Current status (if already responded)
                  if (provider.availabilityStatus != null) ...[
                    _StatusBanner(status: provider.availabilityStatus!),
                    const SizedBox(height: 24),
                    const Text(
                      'Change your response:',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    const Text(
                      'Are you coming today?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Error
                  if (provider.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.yourTurnBg,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.yourTurn.withAlpha(76)),
                      ),
                      child: Text(
                        provider.error!,
                        style: const TextStyle(
                          color: AppColors.yourTurn,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // YES button
                  _AvailabilityButton(
                    label: "YES, I'M COMING",
                    emoji: '✅',
                    color: AppColors.waiting,
                    isSelected: provider.availabilityStatus == 'coming',
                    isDisabled: provider.isSubmitting,
                    onTap: () => _handleSubmit('coming'),
                  ),
                  const SizedBox(height: 16),

                  // NO button
                  _AvailabilityButton(
                    label: "NO, I'M NOT COMING",
                    emoji: '❌',
                    color: AppColors.yourTurn,
                    isSelected: provider.availabilityStatus == 'not_coming',
                    isDisabled: provider.isSubmitting,
                    onTap: () => _handleSubmit('not_coming'),
                  ),

                  if (provider.isSubmitting) ...[
                    const SizedBox(height: 24),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final isComing = status == 'coming';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isComing ? AppColors.waitingBg : AppColors.yourTurnBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isComing ? AppColors.waiting : AppColors.yourTurn)
              .withAlpha(76),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Text(isComing ? '✅' : '❌', style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: isComing ? AppColors.waiting : AppColors.yourTurn,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isComing
                      ? 'You are marked as coming today'
                      : 'You are marked as not coming today',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isComing ? AppColors.waiting : AppColors.yourTurn,
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

class _AvailabilityButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _AvailabilityButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDisabled
                    ? AppColors.textSecondary
                    : (isSelected ? color : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/storage/session_storage.dart';
import '../../shared/widgets/action_card.dart';
import '../../shared/widgets/notification_banner.dart';
import '../../shared/widgets/language_selector_sheet.dart';
import '../token/token_provider.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({Key? key}) : super(key: key);

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  String _patientName = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final storage = await SessionStorage.getInstance();
    final name = storage.getPatientName() ?? 'Patient';
    if (mounted) {
      setState(() {
        _patientName = name;
      });
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'ArogyaMitra',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.base),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome,',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _patientName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Notification Banner (Mocked for UI purposes)
              NotificationBanner(
                title: 'Hospital Welcome',
                message: 'Welcome to the ArogyaMitra patient portal.',
                timeText: 'Just now',
                onTap: () {
                  // Normally routes to notification detail or inbox
                },
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Action Grid (2x2)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.base,
                crossAxisSpacing: AppSpacing.base,
                childAspectRatio: 1.1,
                children: [
                  ActionCard(
                    title: 'New Case',
                    icon: Icons.person_add_alt_1_outlined,
                    iconColor: AppColors.primary,
                    iconBgColor: AppColors.primaryLight,
                    onTap: () => Navigator.pushNamed(context, AppRouter.newCase),
                  ),
                  ActionCard(
                    title: 'Old Case',
                    icon: Icons.history_outlined,
                    iconColor: AppColors.secondary,
                    iconBgColor: AppColors.secondaryContainer,
                    onTap: () => Navigator.pushNamed(context, AppRouter.oldCase),
                  ),
                  ActionCard(
                    title: 'My Token',
                    icon: Icons.receipt_long_outlined,
                    iconColor: AppColors.warning,
                    iconBgColor: AppColors.warning.withOpacity(0.1),
                    onTap: () async {
                      final storage = await SessionStorage.getInstance();
                      final tokenId = storage.getActiveTokenId();
                      if (tokenId != null) {
                        if (mounted) Navigator.pushNamed(context, AppRouter.myToken);
                      } else {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No active token found')),
                        );
                      }
                    },
                  ),
                  ActionCard(
                    title: 'Help',
                    icon: Icons.help_outline,
                    iconColor: AppColors.success,
                    iconBgColor: AppColors.success.withOpacity(0.1),
                    onTap: () => Navigator.pushNamed(context, AppRouter.help),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // Language Selector Bottom
              Center(
                child: TextButton.icon(
                  onPressed: _showLanguageSelector,
                  icon: const Icon(Icons.language, color: AppColors.textSecondary, size: 20),
                  label: const Text(
                    'English',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

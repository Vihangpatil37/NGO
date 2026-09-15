import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/language_selector_sheet.dart';
import '../../core/navigation/app_router.dart';
import 'package:hospital_patient_app/l10n/app_localizations.dart';
import '../../core/storage/session_storage.dart';
import '../../core/services/local_notification_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalNotificationService().requestPermission(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.local_hospital_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.hospitalName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: 26,
            ),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.notifications);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.medical_services_outlined,
              color: AppColors.primary,
              size: 26,
            ),
            tooltip: 'Doctor Login',
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.doctorLogin);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.welcomeTitle,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.whatWouldYouLikeToDo,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Option 1: New Case Card
                    _SelectionCard(
                      iconEmoji: '🆕',
                      title: AppLocalizations.of(context)!.newCase,
                      subtitle: AppLocalizations.of(context)!.newCaseSubtitle,
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.newCase);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Option 2: Old Case Card
                    _SelectionCard(
                      iconEmoji: '📋',
                      title: AppLocalizations.of(context)!.oldCase,
                      subtitle: AppLocalizations.of(context)!.oldCaseSubtitle,
                      color: const Color(0xFF00695C), // Deep teal
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.oldCase);
                      },
                    ),


                    const Spacer(),

                    // Quick Language Switcher Banner at bottom
                    InkWell(
                      onTap: () => LanguageSelectorSheet.show(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.translate, size: 20, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'ગુજરાતી • हिन्दी • English',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String iconEmoji;
  final String title;
  final String subtitle;
  final Color color;
  final bool isProminent;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.iconEmoji,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isProminent = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isProminent ? color.withAlpha(15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(76), width: isProminent ? 3.0 : 2.0),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(isProminent ? 25 : 15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  iconEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

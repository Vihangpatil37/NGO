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
  bool _hasActiveToken = false;
  String? _activeTokenId;
  int? _activeTokenNumber;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkActiveSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalNotificationService().requestPermission(context: context);
    });
  }

  Future<void> _checkActiveSession() async {
    final storage = await SessionStorage.getInstance();
    if (mounted) {
      setState(() {
        _hasActiveToken = storage.hasActiveSession();
        _activeTokenId = storage.getActiveTokenId();
        _activeTokenNumber = storage.getTokenNumber();
        _isLoading = false;
      });
    }
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

                    if (!_isLoading && _hasActiveToken) ...[
                      // Active Token Card
                      _SelectionCard(
                        iconEmoji: '🎟',
                        title: AppLocalizations.of(context)!.myToken, // Using 'My Token' as title
                        subtitle: 'Token #${_activeTokenNumber?.toString().padLeft(2, '0') ?? '--'}\nTap to view live status',
                        color: AppColors.yourTurn, // Or another prominent color
                        isProminent: true,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.myToken,
                            arguments: {'tokenId': _activeTokenId},
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

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

                    const SizedBox(height: 16),

                    // Test All 6 Live Notifications Action
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withAlpha(50)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 22),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Test All 6 Notification Types',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () async {
                                  final notifs = [
                                    {
                                      'title': '✅ N01: Registration Confirmed / નોંધણી સફળ',
                                      'body': 'Your OPD token is #27. Please keep this token with you.',
                                      'priority': 'normal'
                                    },
                                    {
                                      'title': '⏳ N02: Your Turn Is Near / વારો નજીક છે',
                                      'body': 'Your token #27 is coming soon. Only 3 patients ahead.',
                                      'priority': 'high'
                                    },
                                    {
                                      'title': '🚨 N03: YOUR TURN / તમારો વારો આવી ગયો!',
                                      'body': 'Token #27 has been called. Please proceed to Doctor Room 1.',
                                      'priority': 'urgent'
                                    },
                                    {
                                      'title': '📢 N04: Hospital Notice / હોસ્પિટલ નોટિસ',
                                      'body': 'OPD registration will close at 12:30 PM today.',
                                      'priority': 'high'
                                    },
                                    {
                                      'title': '🩺 N05: Doctor Unavailable / ડૉક્ટર અનુપલબ્ધ',
                                      'body': 'Dr. Rajesh Sharma is unavailable today. Please visit desk.',
                                      'priority': 'high'
                                    },
                                    {
                                      'title': '🚪 N06: OPD Closed / ઓપીડી બંધ',
                                      'body': 'Today OPD session closed. OPD resumes tomorrow at 9:00 AM.',
                                      'priority': 'urgent'
                                    },
                                  ];

                                  for (int i = 0; i < notifs.length; i++) {
                                    final n = notifs[i];
                                    await LocalNotificationService().showNotification(
                                      title: n['title']!,
                                      body: n['body']!,
                                      priority: n['priority']!,
                                    );
                                    if (i < notifs.length - 1) {
                                      await Future.delayed(const Duration(milliseconds: 1500));
                                    }
                                  }

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('🎉 All 6 Notification Types sent to your phone!'),
                                        backgroundColor: AppColors.success,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Fire All 6', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Sends N01 Confirmed, N02 Turn Near, N03 Called, N04 Notice, N05 Doctor Absent, N06 OPD Closed to your status bar.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary.withAlpha(200),
                              ),
                            ),
                          ),
                        ],
                      ),
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

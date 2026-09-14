import 'package:flutter/material.dart';
import '../../core/navigation/app_router.dart';
import '../../core/storage/session_storage.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Wait for at least 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final storage = await SessionStorage.getInstance();
    final hasPatientSession = storage.hasActiveSession();
    final hasDoctorSession = storage.hasDoctorSession();

    // Check if launched from notification
    // If not, route based on existing session
    if (hasDoctorSession) {
      Navigator.pushReplacementNamed(context, AppRouter.doctorAvailability);
    } else if (hasPatientSession) {
      Navigator.pushReplacementNamed(context, AppRouter.patientHome);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Logo and Title
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'ArogyaMitra',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Healthcare\nCloser to You',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              child: Column(
                children: [
                  const Text(
                    'A Healthier Tomorrow, Together',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

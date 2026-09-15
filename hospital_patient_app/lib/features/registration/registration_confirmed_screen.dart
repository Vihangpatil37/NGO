import 'package:flutter/material.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/l10n.dart';
import 'package:provider/provider.dart';
import '../../features/onboarding/locale_provider.dart';

class RegistrationConfirmedScreen extends StatelessWidget {
  final String caseNumber;
  final String patientName;

  const RegistrationConfirmedScreen({
    Key? key,
    required this.caseNumber,
    required this.patientName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocaleProvider>(context).loc;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 100,
              ),
              const SizedBox(height: 32),
              
              Text(
                'Registration Successful!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                '${loc.patientName}: $patientName',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.inkMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Container(
                margin: const EdgeInsets.symmetric(vertical: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      loc.caseId,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.inkLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      caseNumber,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.welcome,
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

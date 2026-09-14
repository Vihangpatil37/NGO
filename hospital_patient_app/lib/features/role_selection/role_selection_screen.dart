import 'package:flutter/material.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/role_selection_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              // Header
              const Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'ArogyaMitra',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Please tell us who you are',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              // Cards
              RoleSelectionCard(
                title: 'I am a Patient',
                description: 'Book appointments, view updates and more',
                icon: Icons.person_outline,
                baseColor: AppColors.primary,
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.patientLogin);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              RoleSelectionCard(
                title: 'I am a Doctor',
                description: 'Manage your schedule and patients',
                icon: Icons.medical_services_outlined,
                baseColor: AppColors.secondary,
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.doctorLogin);
                },
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

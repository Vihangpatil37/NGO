import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/app_router.dart';
import '../../shared/widgets/gradient_header.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/app_text_field.dart';
import 'doctor_provider.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<DoctorProvider>(context, listen: false);
    final success = await provider.login(
      _phoneController.text.trim(),
      _pinController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRouter.doctorAvailability);
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
          const GradientHeader(
            title: 'Doctor Portal',
            subtitle: 'Clinician check-in & OPD availability',
            showBackButton: true,
          ),
          Expanded(
            child: Consumer<DoctorProvider>(
              builder: (context, provider, _) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header banner
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/banner.png',
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Doctor Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter your registered phone number & 6-digit PIN',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // Error banner
                        if (provider.error != null) ...[
                          ErrorBanner(message: provider.error!),
                          const SizedBox(height: 20),
                        ],

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: AppDecorations.glassCard(context, radius: 22),
                          child: Column(
                            children: [
                              // Phone Number field
                              AppTextField(
                                label: 'Phone Number',
                                hint: 'e.g. 9876543210',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                prefixIcon: const Icon(Icons.phone_rounded),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().length != 10) {
                                    return 'Please enter a valid 10-digit phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              // PIN field
                              AppTextField(
                                label: '6-Digit PIN',
                                hint: 'e.g. 123456',
                                controller: _pinController,
                                obscureText: _obscurePassword,
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(Icons.lock_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    size: 20,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                validator: (value) {
                                  if (value == null || value.length != 6) {
                                    return 'Please enter your 6-digit PIN';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Login button
                        PrimaryButton(
                          text: 'LOGIN',
                          icon: Icons.login_rounded,
                          isLoading: provider.isLoading,
                          onPressed: _handleLogin,
                        ),
                      ],
                    ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/session_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/gradient_header.dart';
import '../../core/navigation/app_router.dart';
import 'package:hospital_patient_app/l10n/app_localizations.dart';

class NewCaseScreen extends StatefulWidget {
  const NewCaseScreen({super.key});

  @override
  State<NewCaseScreen> createState() => _NewCaseScreenState();
}

class _NewCaseScreenState extends State<NewCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _villageController = TextEditingController();
  final _ageController = TextEditingController();

  final _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _villageController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.registerNewCase(
        name: _nameController.text.trim(),
        villageName: _villageController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        age: _ageController.text.isNotEmpty
            ? int.tryParse(_ageController.text.trim())
            : null,
      );

      final data = response['data'] as Map<String, dynamic>;
      final int tokenNumber = data['tokenNumber'];
      final String caseNumber = data['caseNumber'] ?? '';
      final int queuePosition = data['queuePosition'] ?? 0;
      final String tokenId = data['tokenId'] ?? '';
      final String sessionToken = data['sessionToken'] ?? '';
      final patient = data['patient'] as Map<String, dynamic>?;
      final String patientName =
          patient?['name'] ?? _nameController.text.trim();

      // Save session locally
      final storage = await SessionStorage.getInstance();
      await storage.saveSession(
        sessionToken: sessionToken,
        tokenId: tokenId,
        tokenNumber: tokenNumber,
        caseNumber: caseNumber,
        patientName: patientName,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRouter.tokenConfirmed,
        arguments: {
          'tokenNumber': tokenNumber,
          'caseNumber': caseNumber,
          'queuePosition': queuePosition,
          'tokenId': tokenId,
          'patientName': patientName,
        },
      );
    } on DuplicateTokenException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showDuplicateTokenDialog(context, e.tokenId, e.message);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showDuplicateTokenDialog(
      BuildContext context, String tokenId, String message) {
    final isDark = AppColors.isDark(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Notice',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(140, 48),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushReplacementNamed(
                AppRouter.myToken,
                arguments: {'tokenId': tokenId},
              );
            },
            child: Text(AppLocalizations.of(context)!.viewMyToken),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Column(
        children: [
          GradientHeader(
            title: l10n.newCase,
            subtitle: l10n.newCaseSubtitle,
            onBack: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.welcome, (route) => false);
              } else {
                Navigator.of(context).pushReplacementNamed(AppRouter.welcome);
              }
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppDecorations.glassCard(context, radius: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.primary)
                                      .withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.badge_outlined,
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.enterDetails,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.newCaseFormSubtitle,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          if (_errorMessage != null) ...[
                            ErrorBanner(message: _errorMessage!),
                            const SizedBox(height: 18),
                          ],

                          // 1. Mobile number
                          AppTextField(
                            label: l10n.mobileNumber,
                            hint: l10n.mobileNumberHint,
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_android_rounded),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (val) {
                              if (val == null || val.trim().length != 10) {
                                return l10n.validationMobile;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // 2. Full name
                          AppTextField(
                            label: l10n.fullName,
                            hint: l10n.fullNameHint,
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            prefixIcon: const Icon(Icons.person_rounded),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return l10n.validationFullName;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // 3. Village name
                          AppTextField(
                            label: l10n.villageName,
                            hint: l10n.villageNameHint,
                            controller: _villageController,
                            textCapitalization: TextCapitalization.words,
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return l10n.validationVillage;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // 4. Age
                          AppTextField(
                            label: l10n.age,
                            hint: l10n.ageHint,
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.calendar_today_outlined),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            validator: (val) {
                              if (val != null && val.trim().isNotEmpty) {
                                final parsed = int.tryParse(val.trim());
                                if (parsed == null ||
                                    parsed < 0 ||
                                    parsed > 130) {
                                  return l10n.validationAge;
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dominant CTA
                    PrimaryButton(
                      text: l10n.registerAndGetToken,
                      icon: Icons.confirmation_number_outlined,
                      isLoading: _isLoading,
                      onPressed: _submitRegistration,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

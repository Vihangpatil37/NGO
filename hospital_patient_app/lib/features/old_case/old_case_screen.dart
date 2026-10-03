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

class OldCaseScreen extends StatefulWidget {
  const OldCaseScreen({super.key});

  @override
  State<OldCaseScreen> createState() => _OldCaseScreenState();
}

class _OldCaseScreenState extends State<OldCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _caseIdController = TextEditingController();

  final _apiService = ApiService();
  bool _isLoading = false;
  bool _caseNotFound = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _caseIdController.dispose();
    super.dispose();
  }

  Future<void> _submitOldCase() async {
    setState(() {
      _errorMessage = null;
      _caseNotFound = false;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phoneNumber = _phoneController.text.trim();
      final caseNumber = _caseIdController.text.trim().toUpperCase();

      final response = await _apiService.registerOldCase(
        phoneNumber: phoneNumber,
        caseNumber: caseNumber,
      );

      final data = response['data'] as Map<String, dynamic>;
      final int tokenNumber = data['tokenNumber'];
      final String resolvedCaseNumber = data['caseNumber'] ?? caseNumber;
      final int queuePosition = data['queuePosition'] ?? 0;
      final String tokenId = data['tokenId'] ?? '';
      final String sessionToken = data['sessionToken'] ?? '';
      final patient = data['patient'] as Map<String, dynamic>?;
      final String patientName = patient?['name'] ?? 'Patient';

      // Save session
      final storage = await SessionStorage.getInstance();
      await storage.saveSession(
        sessionToken: sessionToken,
        tokenId: tokenId,
        tokenNumber: tokenNumber,
        caseNumber: resolvedCaseNumber,
        patientName: patientName,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRouter.tokenConfirmed,
        arguments: {
          'tokenNumber': tokenNumber,
          'caseNumber': resolvedCaseNumber,
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
        _isLoading = false;
        if (e.toString().toLowerCase().contains('find this case') ||
            e.toString().toLowerCase().contains('case_not_found') ||
            e.toString().toLowerCase().contains('not found')) {
          _caseNotFound = true;
        } else {
          _errorMessage = e.toString();
        }
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

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Column(
        children: [
          GradientHeader(
            title: l10n.oldCase,
            subtitle: l10n.oldCaseSubtitle,
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
              child: _caseNotFound
                  ? _buildCaseNotFoundView()
                  : _buildFormView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = AppColors.isDark(context);

    return Form(
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
                                ? AppColors.darkAccent
                                : AppColors.accent)
                            .withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: isDark
                            ? AppColors.darkAccent
                            : AppColors.accent,
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
                            l10n.oldCaseFormSubtitle,
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

                // 2. Case ID
                AppTextField(
                  label: l10n.caseId,
                  hint: l10n.caseIdHint,
                  controller: _caseIdController,
                  textCapitalization: TextCapitalization.characters,
                  prefixIcon: const Icon(Icons.tag_rounded),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return l10n.validationCaseId;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            text: l10n.continueAndGetToken,
            icon: Icons.confirmation_number_outlined,
            isLoading: _isLoading,
            onPressed: _submitOldCase,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCaseNotFoundView() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = AppColors.isDark(context);
    final errorColor =
        isDark ? AppColors.darkYourTurn : const Color(0xFFC62828);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (_, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: errorColor.withAlpha(isDark ? 40 : 25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: errorColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.caseNotFound,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppDecorations.glassCard(context, radius: 18),
            child: Text(
              l10n.caseNotFoundSub,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: l10n.tryAgain,
            icon: Icons.refresh_rounded,
            onPressed: () {
              setState(() {
                _caseNotFound = false;
                _isLoading = false;
              });
            },
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              side: BorderSide(
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                width: 1.8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.help);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.contactHospital,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
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

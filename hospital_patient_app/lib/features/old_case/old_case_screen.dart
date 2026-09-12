import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/session_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/info_card.dart';
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

      final storage = await SessionStorage.getInstance();
      final langCode = storage.getLanguageCode();

      // Register old case for today's queue
      final response = await _apiService.registerOldCase(
        phoneNumber: phoneNumber,
        caseNumber: caseNumber,
        preferredLanguage: langCode,
      );

      final data = response['data'] as Map<String, dynamic>;
      final int tokenNumber = data['tokenNumber'];
      final String resolvedCaseNumber = data['caseNumber'] ?? caseNumber;
      final int queuePosition = data['queuePosition'] ?? 0;
      final String tokenId = data['tokenId'] ?? '';
      final String sessionToken = data['sessionToken'] ?? '';
      final patient = data['patient'] as Map<String, dynamic>?;
      final String patientName = patient?['name'] ?? 'Patient';

      final String? patientId = patient?['_id']?.toString() ?? patient?['id']?.toString();

      // Save session
      await storage.saveSession(
        sessionToken: sessionToken,
        tokenId: tokenId,
        tokenNumber: tokenNumber,
        caseNumber: resolvedCaseNumber,
        patientName: patientName,
        patientId: patientId,
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

  void _showDuplicateTokenDialog(BuildContext context, String tokenId, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Notice'),
        content: Text(message),
        actions: [
          TextButton(
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.oldCase),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.welcome, (route) => false);
            } else {
              Navigator.of(context).pushReplacementNamed(AppRouter.welcome);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: _caseNotFound ? _buildCaseNotFoundView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.enterDetails,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.oldCaseFormSubtitle,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          if (_errorMessage != null) ...[
            ErrorBanner(message: _errorMessage!),
            const SizedBox(height: 20),
          ],

          // 1. Mobile number
          AppTextField(
            label: AppLocalizations.of(context)!.mobileNumber,
            hint: AppLocalizations.of(context)!.mobileNumberHint,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (val) {
              if (val == null || val.trim().length != 10) {
                return AppLocalizations.of(context)!.validationMobile;
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // 2. Case ID
          AppTextField(
            label: AppLocalizations.of(context)!.caseId,
            hint: AppLocalizations.of(context)!.caseIdHint,
            helperText: '',
            controller: _caseIdController,
            textCapitalization: TextCapitalization.characters,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return AppLocalizations.of(context)!.validationCaseId;
              }
              return null;
            },
          ),
          const SizedBox(height: 36),

          PrimaryButton(
            text: AppLocalizations.of(context)!.continueAndGetToken,
            icon: Icons.confirmation_number_outlined,
            isLoading: _isLoading,
            onPressed: _submitOldCase,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Exact Error Screen specification from Section 7
  Widget _buildCaseNotFoundView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 72,
            color: AppColors.yourTurn,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.caseNotFound,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.caseNotFoundSub,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: AppLocalizations.of(context)!.tryAgain,
            icon: Icons.refresh,
            onPressed: () {
              setState(() {
                _caseNotFound = false;
                _isLoading = false;
              });
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              side: const BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.help);
            },
            child: Text(
              AppLocalizations.of(context)!.contactHospital,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

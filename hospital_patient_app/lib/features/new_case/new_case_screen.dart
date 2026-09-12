import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/session_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/error_banner.dart';
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
      final storage = await SessionStorage.getInstance();
      final langCode = storage.getLanguageCode();

      final response = await _apiService.registerNewCase(
        name: _nameController.text.trim(),
        villageName: _villageController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        age: _ageController.text.isNotEmpty ? int.tryParse(_ageController.text.trim()) : null,
        preferredLanguage: langCode,
      );

      final data = response['data'] as Map<String, dynamic>;
      final int tokenNumber = data['tokenNumber'];
      final String caseNumber = data['caseNumber'] ?? '';
      final int queuePosition = data['queuePosition'] ?? 0;
      final String tokenId = data['tokenId'] ?? '';
      final String sessionToken = data['sessionToken'] ?? '';
      final patient = data['patient'] as Map<String, dynamic>?;
      final String patientName = patient?['name'] ?? _nameController.text.trim();

      final String? patientId = patient?['_id']?.toString() ?? patient?['id']?.toString();

      // Save session locally
      await storage.saveSession(
        sessionToken: sessionToken,
        tokenId: tokenId,
        tokenNumber: tokenNumber,
        caseNumber: caseNumber,
        patientName: patientName,
        patientId: patientId,
      );

      if (!mounted) return;

      // Navigate to Token Confirmed Screen (Section 8)
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
        title: Text(AppLocalizations.of(context)!.newCase),
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
          child: Form(
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
                  AppLocalizations.of(context)!.newCaseFormSubtitle,
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
                  helperText: '',
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

                // 2. Full name
                AppTextField(
                  label: AppLocalizations.of(context)!.fullName,
                  hint: AppLocalizations.of(context)!.fullNameHint,
                  helperText: '',
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return AppLocalizations.of(context)!.validationFullName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 3. Village name
                AppTextField(
                  label: AppLocalizations.of(context)!.villageName,
                  hint: AppLocalizations.of(context)!.villageNameHint,
                  controller: _villageController,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return AppLocalizations.of(context)!.validationVillage;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 4. Age
                AppTextField(
                  label: AppLocalizations.of(context)!.age,
                  hint: AppLocalizations.of(context)!.ageHint,
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: (val) {
                    if (val != null && val.trim().isNotEmpty) {
                      final parsed = int.tryParse(val.trim());
                      if (parsed == null || parsed < 0 || parsed > 130) {
                        return AppLocalizations.of(context)!.validationAge;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // Dominant CTA
                PrimaryButton(
                  text: AppLocalizations.of(context)!.registerAndGetToken,
                  icon: Icons.confirmation_number_outlined,
                  isLoading: _isLoading,
                  onPressed: _submitRegistration,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

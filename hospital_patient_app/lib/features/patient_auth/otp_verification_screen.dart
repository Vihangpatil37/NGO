import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/otp_input.dart';
import 'auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  Timer? _timer;
  int _secondsLeft = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsLeft = 30;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _resendOtp(AuthProvider provider) {
    if (_canResend && provider.phoneNumber != null) {
      provider.sendOtp(provider.phoneNumber!);
      _startTimer();
    }
  }

  void _onOtpCompleted(String otp, AuthProvider provider) {
    provider.verifyOtp(otp);
  }

  String _maskPhone(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 5)} ${phone.substring(5, 7)}XXX';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Listen to state changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.state == AuthState.authenticated) {
              Navigator.pushNamedAndRemoveUntil(context, AppRouter.patientHome, (r) => false);
            } else if (authProvider.state == AuthState.profileIncomplete) {
              Navigator.pushReplacementNamed(context, AppRouter.patientProfile);
            } else if (authProvider.state == AuthState.error && authProvider.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authProvider.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
              authProvider.resetError();
            }
          });

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.message_outlined, size: 48, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Enter OTP',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    "We've sent a 6-digit code to\n+91 ${_maskPhone(authProvider.phoneNumber ?? '')}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  
                  // OTP Input
                  OtpInput(
                    length: 6,
                    onCompleted: (otp) => _onOtpCompleted(otp, authProvider),
                  ),
                  
                  const SizedBox(height: AppSpacing.xxl),
                  
                  if (authProvider.state == AuthState.verifying)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  else
                    Center(
                      child: TextButton(
                        onPressed: _canResend ? () => _resendOtp(authProvider) : null,
                        child: Text(
                          _canResend 
                              ? 'Resend OTP' 
                              : 'Resend OTP in 00:${_secondsLeft.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _canResend ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

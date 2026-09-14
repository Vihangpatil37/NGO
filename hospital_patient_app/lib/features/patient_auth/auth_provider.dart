import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/session_storage.dart';

enum AuthState {
  unknown,
  checkingSession,
  unauthenticated,
  otpSent,
  verifying,
  authenticated,
  profileIncomplete,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  AuthState _state = AuthState.unknown;
  AuthState get state => _state;

  String? _verificationId;
  String? _phoneNumber;
  String? _errorMessage;

  String? get phoneNumber => _phoneNumber;
  String? get errorMessage => _errorMessage;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(AuthState.error);
  }

  Future<void> sendOtp(String phone) async {
    _phoneNumber = phone;
    _setState(AuthState.verifying); // Use verifying as loading state for send
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (often works on Android)
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setError(_parseFirebaseError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setState(AuthState.otpSent);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _setError('Unable to send OTP. Please try again.');
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (_verificationId == null) {
      _setError('Session expired. Please request a new OTP.');
      return;
    }
    
    _setState(AuthState.verifying);
    
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        _setError('The OTP is incorrect. Please check and try again.');
      } else {
        _setError('OTP verification failed. Please try again.');
      }
    } catch (e) {
      _setError('Something went wrong. Please try again.');
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      
      if (user != null) {
        // Get Firebase ID Token
        final String idToken = await user.getIdToken() ?? '';
        
        // Authenticate with backend
        final result = await _apiService.verifyFirebaseToken(idToken);
        final data = result['data'];
        
        // Save session locally
        if (data != null && data['sessionToken'] != null) {
          final storage = await SessionStorage.getInstance();
          await storage.saveSession(
            sessionToken: data['sessionToken'],
            tokenId: data['patient']['activeTokenId'] ?? '',
            tokenNumber: data['patient']['activeTokenNumber'] ?? 0,
            caseNumber: data['patient']['caseNumber'] ?? '',
            patientName: data['patient']['fullName'] ?? '',
            patientId: data['patient']['_id'] ?? '',
          );
        }

        if (data != null && data['isNewPatient'] == true) {
          _setState(AuthState.profileIncomplete);
        } else {
          _setState(AuthState.authenticated);
        }
      } else {
        _setError('Authentication failed. Please try again.');
      }
    } catch (e) {
      _setError('Server verification failed. Please try again later.');
    }
  }

  Future<void> completeProfile(String fullName, int age, String village) async {
    _setState(AuthState.verifying);
    try {
      if (_phoneNumber == null) {
        throw Exception("Phone number missing");
      }
      
      // We'll call the new case endpoint but bypass OTP requirement since we are auth'd
      await _apiService.registerNewCase(
        phoneNumber: _phoneNumber!,
        name: fullName,
        villageName: village,
        age: age,
      );
      
      _setState(AuthState.authenticated);
    } catch (e) {
      _setError('Failed to save profile. Please try again.');
    }
  }

  void resetError() {
    if (_state == AuthState.error) {
      if (_verificationId != null) {
        _setState(AuthState.otpSent);
      } else {
        _setState(AuthState.unauthenticated);
      }
    }
  }
  
  String _parseFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Please enter a valid mobile number.';
      case 'network-request-failed':
        return 'Please check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

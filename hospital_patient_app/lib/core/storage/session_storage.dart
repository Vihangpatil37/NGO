import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SessionStorage {
  static SessionStorage? _instance;
  static SharedPreferences? _prefs;

  SessionStorage._();

  static Future<SessionStorage> getInstance() async {
    _instance ??= SessionStorage._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Session Token
  Future<void> saveSession({
    required String sessionToken,
    required String tokenId,
    required int tokenNumber,
    required String caseNumber,
    required String patientName,
  }) async {
    await _prefs?.setString(AppConstants.keySessionToken, sessionToken);
    await _prefs?.setString(AppConstants.keyActiveTokenId, tokenId);
    await _prefs?.setInt(AppConstants.keyTokenNumber, tokenNumber);
    await _prefs?.setString(AppConstants.keyCaseNumber, caseNumber);
    await _prefs?.setString(AppConstants.keyPatientName, patientName);
  }

  String? getSessionToken() => _prefs?.getString(AppConstants.keySessionToken);
  String? getActiveTokenId() => _prefs?.getString(AppConstants.keyActiveTokenId);
  int? getTokenNumber() => _prefs?.getInt(AppConstants.keyTokenNumber);
  String? getCaseNumber() => _prefs?.getString(AppConstants.keyCaseNumber);
  String? getPatientName() => _prefs?.getString(AppConstants.keyPatientName);

  bool hasActiveSession() {
    final token = getSessionToken();
    final tokenId = getActiveTokenId();
    return token != null && token.isNotEmpty && tokenId != null && tokenId.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _prefs?.remove(AppConstants.keySessionToken);
    await _prefs?.remove(AppConstants.keyActiveTokenId);
    await _prefs?.remove(AppConstants.keyTokenNumber);
    await _prefs?.remove(AppConstants.keyCaseNumber);
    await _prefs?.remove(AppConstants.keyPatientName);
  }

  // Language preference
  String getLanguageCode() => _prefs?.getString(AppConstants.keyLanguageCode) ?? 'gu';

  Future<void> setLanguageCode(String code) async {
    await _prefs?.setString(AppConstants.keyLanguageCode, code);
  }

  // --- Doctor Session (isolated from patient session) ---

  Future<void> saveDoctorSession({
    required String token,
    required String doctorPhone,
    required String doctorObjectId,
    required String doctorName,
    String? specialization,
  }) async {
    await _prefs?.setString(AppConstants.keyDoctorSessionToken, token);
    await _prefs?.setString(AppConstants.keyDoctorPhone, doctorPhone);
    await _prefs?.setString(AppConstants.keyDoctorObjectId, doctorObjectId);
    await _prefs?.setString(AppConstants.keyDoctorName, doctorName);
    if (specialization != null) {
      await _prefs?.setString(AppConstants.keyDoctorSpecialization, specialization);
    }
  }

  String? getDoctorSessionToken() => _prefs?.getString(AppConstants.keyDoctorSessionToken);
  String? getDoctorPhone() => _prefs?.getString(AppConstants.keyDoctorPhone);
  String? getDoctorObjectId() => _prefs?.getString(AppConstants.keyDoctorObjectId);
  String? getDoctorName() => _prefs?.getString(AppConstants.keyDoctorName);
  String? getDoctorSpecialization() => _prefs?.getString(AppConstants.keyDoctorSpecialization);

  bool hasDoctorSession() {
    final token = getDoctorSessionToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearDoctorSession() async {
    await _prefs?.remove(AppConstants.keyDoctorSessionToken);
    await _prefs?.remove(AppConstants.keyDoctorPhone);
    await _prefs?.remove(AppConstants.keyDoctorObjectId);
    await _prefs?.remove(AppConstants.keyDoctorName);
    await _prefs?.remove(AppConstants.keyDoctorSpecialization);
  }
}

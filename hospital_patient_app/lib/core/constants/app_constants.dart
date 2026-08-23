class AppConstants {
  static const String hospitalName = 'Shri Satya sai gramya arogya mandir';
  static const String hospitalHelpline = '+91 98765 43210';
  static const String hospitalAddress = 'Gramya Arogya Mandir Campus, Main Road';

  // Default API server endpoints (localhost or LAN IP)
  // Wi-Fi LAN IP for physical device: 192.168.1.239, for Android emulator: 10.0.2.2
  static const String defaultApiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.1.239:4000',
  );
  static const String apiBasePath = '/api/v1/patient';

  // Storage keys
  static const String keySessionToken = 'session_token';
  static const String keyActiveTokenId = 'active_token_id';
  static const String keyTokenNumber = 'token_number';
  static const String keyCaseNumber = 'case_number';
  static const String keyPatientName = 'patient_name';
  static const String keyLanguageCode = 'app_language_code';
}

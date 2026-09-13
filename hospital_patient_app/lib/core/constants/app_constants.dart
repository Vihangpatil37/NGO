class AppConstants {
  static const String hospitalName = 'ArogyaMitra';
  static const String hospitalHelpline = '+91 98765 43210';
  static const String hospitalAddress = 'Gramya Arogya Mandir Campus, Main Road';

  // Default API server endpoints (localhost or LAN IP)
  // Wi-Fi LAN IP for physical device: 192.168.1.239, for Android emulator: 10.0.2.2
  static const String defaultApiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:4000',
  );
  static const String apiBasePath = '/api/v1/patient';

  // Storage keys
  static const String keySessionToken = 'session_token';
  static const String keyActiveTokenId = 'active_token_id';
  static const String keyTokenNumber = 'token_number';
  static const String keyCaseNumber = 'case_number';
  static const String keyPatientName = 'patient_name';
  static const String keyPatientId = 'patient_id';
  static const String keyLanguageCode = 'app_language_code';

  // Doctor session keys
  static const String keyDoctorSessionToken = 'doctor_session_token';
  static const String keyDoctorPhone = 'doctor_phone';
  static const String keyDoctorObjectId = 'doctor_object_id';
  static const String keyDoctorName = 'doctor_name';
  static const String keyDoctorSpecialization = 'doctor_specialization';

  // Doctor API
  static const String doctorApiBasePath = '/api/doctors';
}

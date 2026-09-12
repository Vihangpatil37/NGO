import 'package:flutter/material.dart';
import '../storage/session_storage.dart';
import '../network/api_service.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale;
  final SessionStorage _storage;

  LocaleProvider(this._storage) : _locale = Locale(_storage.getLanguageCode());

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'hi', 'gu'].contains(locale.languageCode)) return;
    
    _locale = locale;
    await _storage.setLanguageCode(locale.languageCode);
    notifyListeners();

    final patientId = _storage.getPatientId();
    if (patientId != null && patientId.isNotEmpty) {
      try { await ApiService().updateLanguagePreference(patientId: patientId, languageCode: locale.languageCode); } catch (_) {}
    }
  }
}

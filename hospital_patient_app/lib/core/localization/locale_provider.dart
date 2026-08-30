import 'package:flutter/material.dart';
import '../storage/session_storage.dart';

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
  }
}

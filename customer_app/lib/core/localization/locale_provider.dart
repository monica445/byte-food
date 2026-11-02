import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLanguage(String languageCode) {
    if (languageCode != 'en' && languageCode != 'km') return;

    final nextLocale = Locale(languageCode);
    if (_locale == nextLocale) return;

    _locale = nextLocale;
    notifyListeners();
  }
}

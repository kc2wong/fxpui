import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/language.dart';
import '../localization/language_en.dart';
import '../localization/language_zh_hant.dart';
import '../model/constant.dart';
import '../util/logger.dart';

class LocaleService {
  static const String prefSelectedLanguageCode = "SelectedLanguageCode";

  static const supportedLanguages = [languageEn, languageHant, languageHans];

  Future<Locale> setLocale(String languageCode) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(prefSelectedLanguageCode, languageCode);
    return languageToLocale(languageCode);
  }

  Future<Locale> getLocale() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? languageCode = _prefs.getString(prefSelectedLanguageCode);
    logger.i('locale_constant.getLocale(): return languageCode = $languageCode');
    return languageToLocale(languageCode);
  }

  List<Locale> getSupportedLocales() {
    return [
      const Locale('en'),
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans')
    ];
  }

  Locale languageToLocale(String? languageCode) {
    switch (languageCode) {
      case languageHant:
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
      case languageHans:
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
      case languageEn:
      default:
        return const Locale('en');
    }
  }

  String localeToLanguageStr(Locale locale) {
    String language = (locale.scriptCode ?? locale.languageCode).toLowerCase();
    return supportedLanguages.contains(language) ? language : languageEn;
  }

  Language localeToLanguage(Locale locale) {
    final languageStr = localeToLanguageStr(locale);
    if (languageStr == languageHant) {
      return LanguageZhHant();
    }
    else {
      return LanguageEn();
    }
  }
}

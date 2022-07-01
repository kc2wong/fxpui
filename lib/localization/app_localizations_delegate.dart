
import 'package:flutter/material.dart';

import 'language.dart';
import 'language_en.dart';
import 'language_zh_hant.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<Language> {

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<Language> load(Locale locale) async {
    return getLanguage(locale);
  }

  Language getLanguage(Locale locale) {
    switch (locale.languageCode.toLowerCase()) {
      case 'en':
        return LanguageEn();
      case 'zh':
        if ('Hant' == locale.scriptCode) {
          return LanguageZhHant();
        }
        else {
          return LanguageEn();
        }
      default:
        return LanguageEn();
    }
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<Language> old) => true;
}
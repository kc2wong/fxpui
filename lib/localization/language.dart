import 'package:flutter/material.dart';

import '../model/payment.dart';

import 'language_zh_hant.dart';
import 'language_en.dart';

abstract class Language {

  static Language of(BuildContext context) {
    final language = Localizations.of<Language>(context, Language);
    return language ?? LanguageEn();
  }

  static Language fromLocale(Locale locale) {
    return locale.languageCode !=  'en' ? LanguageZhHant() : LanguageEn();
  }

  String get appName;

  String get languageCode;

  String get english;

  String get traditionChinese;

  String get welcomeTitle;

  String get welcomeSubtitle;

  String get add;

  String get from;

  String get to;

  String get ccy;

  String get amount;

  String get fromAmount;

  String get toAmount;

  String get searchCriteria;

  String get reset;

  String get refresh;

  String get export;

  String get submit;

  String get collapseSearchPanel;

  String get expandSearchPanel;

  String get yes;

  String get no;

  String get next;

  String get previous;

  String get cancel;

  String get changeLanguage;

  String lastRefreshAt(DateTime dateTime);

  String getErrorMessage(String errorCode, List<String> errorParam);

  Menu get menu;
  LoginPage get loginPage;
  PaymentPage get paymentPage;
  AccountPage get accountPage;
}

abstract class Menu {
  String get signIn;
  String get about;
  String get paymentView;
  String get dealView;
  String get dealMonitorView;
  String get setting;
  String get switchToDarkTheme;
  String get switchToLightTheme;
  String get signOut;
}

abstract class LoginPage {
  String get greeting;
  String get signInHint;
  String get selectUserid;
  String get enterUserid;
  String get orLabel;
  String get signIn;
}

abstract class PaymentPage {
  String get listPayment;
  String get newPayment;
  String get editPayment;
  String get cancelPayment;
  String get viewPayment;
  String get submitPayment;
  String get requestQuote;

  String get requestStatus;
  String get direction;
  String get outgoing;
  String get incoming;
  String get instructionId;
  String getEnrichmentStatusDescription(EnrichmentRequestStatus status);
  EnrichmentRequestStatus? getEnrichmentStatus(String description);
  String get account;
  String get accountDetail;
  String get account1;
  String get account2;
  String accountName(String? name);
  String accountAlert(String? alert);
  String get executeDateFromTo;
  String get executeDate;
  String get initiatedBy;
  String get bankSell;
  String get bankBuy;
  String get fxRef;
  String get remainingCcy;
  String get remainingAmount;
  String get dealCcy;
  String get dealAmount;
  String get contraCcy;
  String get contraAmount;
  String get traderComment;
  String get fxd;
  String get fxt;
  String get valueDate;
  String get product;
  String get ccyPair;
  String get rate;
  String get populate;
  String get matching;
  String get booking;
  String get matchPayment;
  String get newBooking;
  String get confirmSwitchSiteTitle;
  String confirmSwitchSite(String oldSite, String newSite);
  String confirmMatching(String fxRef);
  String get matchingRequestSubmitted;
  String get confirmBooking;
  String get bookingRequestSubmitted;
  String get confirmCancelPayment;
  String get cancelRequestSubmitted;
  String get paymentDetail;
  String get chooseYourAction;
  String get enrichmentResult;
  String get memos;

  String get start;

}

abstract class AccountPage {
  String get fxAccount;
  String get name;
  String get status;
  String get type;
  String get ref;
}

import 'package:get_it/get_it.dart';

import 'navigation.dart';
import 'authentication.dart';
import 'locale.dart';
import 'site.dart';
import 'theme_service.dart';
import 'currency.dart';
import 'payment.dart';
import 'account.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => LocaleService());
  locator.registerLazySingleton(() => ThemeService());
  locator.registerLazySingleton(() => CurrencySearchService());
  locator.registerLazySingleton(() => SiteSearchService());
  locator.registerLazySingleton(() => FxAccountSearchService());
  locator.registerLazySingleton(() => PaymentSearchService());
}

NavigationService getNavigationService() {
  return locator<NavigationService>();
}

AuthenticationService getAuthenticationService() {
  return locator<AuthenticationService>();
}

PaymentSearchService getSearchPaymentService() {
  return locator<PaymentSearchService>();
}

CurrencySearchService getCurrencyService() {
  return locator<CurrencySearchService>();
}

SiteSearchService getSiteService() {
  return locator<SiteSearchService>();
}

FxAccountSearchService getFxAccountService() {
  return locator<FxAccountSearchService>();
}

LocaleService getLocaleService() {
  return locator<LocaleService>();
}

ThemeService getThemeService() {
  return locator<ThemeService>();
}
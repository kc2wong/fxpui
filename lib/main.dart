import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:one_context/one_context.dart';

import 'bloc/authentication_bloc.dart';
import 'bloc/enrichment_request_bloc.dart';
import 'bloc/event/system_event.dart';
import 'bloc/site_bloc.dart';
import 'bloc/state/authentication_state.dart';
import 'bloc/state/system_state.dart';
import 'bloc/system_bloc.dart';
import 'bloc/account_bloc.dart';
import 'bloc/currency_bloc.dart';
import 'bloc/enrichment_request_search_bloc.dart';
import 'localization/app_localizations_delegate.dart';
import 'model/system.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/route.dart';
import 'service/service_locator.dart';
import 'theme/app_theme.dart';
import 'util/logger.dart';
import 'widget/toast_message.dart';

final GlobalKey globalKey = GlobalKey();

final toastMap = {
  ToastType.success: _ToastSetting(backgroundColor: Colors.green.shade100, icon: const Icon(Icons.check_circle_outline, size: 32, color: Colors.green), textColor: Colors.black54, autoDismissMilliseconds: 3000),
  ToastType.info: _ToastSetting(backgroundColor: Colors.grey.shade300, icon: const Icon(Icons.info_outline, size: 32, color: Colors.black54), textColor: Colors.black54, autoDismissMilliseconds: 6000),
  ToastType.error: _ToastSetting(backgroundColor: Colors.red.shade50, icon: Icon(Icons.cancel_outlined, size: 32, color: Colors.red.shade800), textColor: Colors.black54),
  ToastType.warning: _ToastSetting(backgroundColor: Colors.amber.shade50, icon: const Icon(Icons.info_outline, size: 32, color: Colors.black38), textColor: Colors.black54, autoDismissMilliseconds: 3000),
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();

  final locale = await getLocaleService().getLocale();
  final themeMode = await getThemeService().loadTheme();
  final localUsers = await getAuthenticationService().getLocalUsers();
  final authentication = await getAuthenticationService().getAuthentication();
  logger.i('Initial setting : locale = $locale, themeMode = $themeMode');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) =>
              AuthenticationBloc(authenticationService: getAuthenticationService(), authentication: authentication),
        ),
        BlocProvider<SystemBloc>(
          create: (BuildContext context) => SystemBloc(locale, themeMode, localUsers),
        ),
        BlocProvider<CurrencySearchBloc>(
          create: (BuildContext context) =>
              CurrencySearchBloc(getCurrencyService()),
        ),
        BlocProvider<SiteSearchBloc>(
          create: (BuildContext context) =>
              SiteSearchBloc(getSiteService()),
        ),
        BlocProvider<FxAccountSearchBloc>(
          create: (BuildContext context) =>
              FxAccountSearchBloc(getFxAccountService()),
        ),
        BlocProvider<EnrichmentRequestBloc>(
          create: (BuildContext context) =>
              EnrichmentRequestBloc(getSearchPaymentService()),
        ),
        BlocProvider<EnrichmentRequestSearchBloc>(
          create: (BuildContext context) =>
              EnrichmentRequestSearchBloc(getSearchPaymentService(), DateTime.now()),
        ),
      ],
      child: FxpApp(authentication != null),
    ),
  );
}

class FxpApp extends StatefulWidget {
  final bool _authenticated;

  const FxpApp(this._authenticated, {Key? key}) : super(key: key);

  @override
  _FxpAppState createState() => _FxpAppState();
}

class _FxpAppState extends State<FxpApp> {
  // final bool _authenticated;
  String? _overlayId;
  final GlobalKey<ToastMessagePaneState> _toastMessagePanelState = GlobalKey<ToastMessagePaneState>();

  @override
  Widget build(BuildContext ctx) {
    AppLocalizationsDelegate appLocalizationsDelegate = AppLocalizationsDelegate();
    final systemBloc = BlocProvider.of<SystemBloc>(context);

    final blocBuilder = BlocBuilder<SystemBloc, SystemState>(
      buildWhen: (oldState, newState) => oldState.themeMode != newState.themeMode || oldState.locale != newState.locale,
      builder: (context, systemState) {
        return MaterialApp(
          builder: OneContext().builder,
          // scaffoldMessengerKey: _messengerKey,
          locale: systemState.locale,
          localizationsDelegates: [
            appLocalizationsDelegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: getLocaleService().getSupportedLocales(),
          key: globalKey,
          navigatorKey: getNavigationService().navigatorKey,
          initialRoute: RouteName.routeNameHome,
          onGenerateInitialRoutes: (_) {
            return [
              MaterialPageRoute(
                builder: (context) {
                  return widget._authenticated ? const HomePage() : const LoginPage();
                  // return widget._authenticated ? const HomePage() : const HomePage();
                },
              ),
            ];
          },
          routes: {
            RouteName.routeNameHome: (context) => const HomePage(),
            RouteName.routeNameLogin: (context) => const LoginPage(),
          },
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: systemState.themeMode,
          debugShowCheckedModeBanner: false,
        );
      },
    );

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            logger.i('Received AuthenticationState authentication = ${state.authentication}, errorCode = ${state.errorCode}');
            if (state.authentication != null) {
              // After login success
              getNavigationService().navigateToHome(true);
            } else {
              if (state.errorCode != null) {
                // After login failed
                systemBloc.showToast(state.errorCode!, ToastType.error);
              } else {
                // After logout
                getNavigationService().navigateTo(RouteName.routeNameLogin);
                BlocProvider.of<EnrichmentRequestSearchBloc>(context).resetState();
                BlocProvider.of<CurrencySearchBloc>(context).resetState();
                BlocProvider.of<SiteSearchBloc>(context).resetState();
              }
            }
          },
        ),
        BlocListener<SystemBloc, SystemState>(
          listenWhen: (oldState, newState) => oldState.loadingIndicatorMode != newState.loadingIndicatorMode || newState.toast.isEmpty || newState.toast.length > oldState.toast.length,
          listener: (context, state) {
            final spinnerColor = (state.themeMode == ThemeMode.light ? AppTheme.light : AppTheme.dark).primaryColor;

            if (state.loadingIndicatorMode == LoadingIndicatorMode.start) {
              _showLoadingIndicator(spinnerColor);
            }
            else if (state.loadingIndicatorMode == LoadingIndicatorMode.stop) {
              _hideLoadingIndicator();
            }

            if (state.toast.isEmpty) {
              _hideToast();
            } else if (state.toast.isNotEmpty) {
              _showToast(context, systemBloc, state.toast);
            }
          },
        ),
      ],
      child: blocBuilder,
    );
  }

  _showLoadingIndicator(Color? color) {
    OneContext().showProgressIndicator(
      backgroundColor: Colors.black26,
      circularProgressIndicatorColor: color ?? Colors.white,
    );
  }

  _hideLoadingIndicator() {
    OneContext().hideProgressIndicator();
  }

  _hideToast() {
    logger.i('hideToast');
    if (_overlayId != null) {
      OneContext().removeOverlay(_overlayId!);
    }
    _overlayId = null;
  }

  _showToast(BuildContext context, SystemBloc systemBloc, List<Toast> toastList) async {
    logger.d('currentState = ${_toastMessagePanelState.currentState}');

    final toast = toastList.last;
    final toastSetting = toastMap[toast.type]!;

    if (_toastMessagePanelState.currentState == null) {
      ToastMessagePane toastMessagePanel = ToastMessagePane(
        key: _toastMessagePanelState,
        width: OneContext().mediaQuery.size.width * 2 / 5,
        message: toast.message,
        color: toastSetting.backgroundColor,
        textColor: toastSetting.textColor,
        icon: toastSetting.icon,
        closeAction: () => systemBloc.add(HideToastEvent(toast)),
        closeTime: toast.createTime.add(Duration(milliseconds: toast.autoDismissMills > 0 ? toast.autoDismissMills : toastSetting.autoDismissMilliseconds?? 0)),
      );
      _overlayId = DateTime.now().microsecondsSinceEpoch.toString();
      OneContext().addOverlay(overlayId: _overlayId!, builder: (_) => toastMessagePanel);
    }
    else {
      _toastMessagePanelState.currentState?.addToastMessage(
        message: toast.message,
        color: toastSetting.backgroundColor,
        textColor: toastSetting.textColor,
        icon: toastSetting.icon,
        closeAction: () => systemBloc.add(HideToastEvent(toast)),
        closeTime: toast.createTime.add(Duration(milliseconds: toastSetting.autoDismissMilliseconds?? 0)),
      );
    }
  }

}

class _ToastSetting {
  Color backgroundColor;
  Icon icon;
  Color textColor;
  int? autoDismissMilliseconds;

  _ToastSetting({
    required this.backgroundColor,
    required this.icon,
    required this.textColor,
    this.autoDismissMilliseconds,
  });
}

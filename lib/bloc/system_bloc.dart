import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './event/system_event.dart';
import './state/system_state.dart';
import '../model/authentication.dart';
import '../model/system.dart';
import '../service/service_locator.dart';
import '../util/logger.dart';

class SystemBloc extends Bloc<SystemEvent, SystemState> {
  SystemBloc(
    Locale locale,
    ThemeMode themeMode,
    List<User> localUsers,
  ) : super(SystemState(locale: locale, themeMode: themeMode, localUsers: localUsers)) {
    on<ChangeLanguageEvent>(_changeLanguage);
    on<ChangeThemeEvent>(_changeTheme);
    on<StartLoadingEvent>(_startLoading);
    on<StopLoadingEvent>(_stopLoading);
    on<ShowToastEvent>(_showToast);
    on<HideToastEvent>(_hideToast);
    on<MarkDirtyEvent>(_markDirty);
    on<MarkCleanEvent>(_markClean);
    on<ChangeSiteEvent>(_changeSite);
  }

  void changeLanguage(String langugageCode) {
    add(
      ChangeLanguageEvent(langugageCode),
    );
  }

  void toggleTheme() {
    add(
      ChangeThemeEvent(state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light),
    );
  }

  void startLoading() {
    add(
      StartLoadingEvent(spinnerColor: state.themeData().primaryColor),
    );
  }

  void stopLoading() {
    add(
      StopLoadingEvent(),
    );
  }

  void showToast(
    String message,
    ToastType toastType, {
    int? autoDismissMillis,
  }) {
    add(
      ShowToastEvent(
        message,
        toastType,
        autoDismissMillis,
      ),
    );
  }

  void hideToast(Toast toast) {
    add(
      HideToastEvent(toast),
    );
  }

  void changeSite(String? siteCode) {
    add(
      ChangeSiteEvent(siteCode),
    );
  }

  Future<void> _startLoading(StartLoadingEvent event, Emitter emit) async {
    logger.i('event = $event');

    final newSystemState = SystemState.startLoading(state);
    if (newSystemState.loadingIndicatorMode == LoadingIndicatorMode.start) {
      emit(newSystemState);
    }
  }

  Future<void> _stopLoading(StopLoadingEvent event, Emitter emit) async {
    logger.i('event = $event');

    final newSystemState = SystemState.stopLoading(state);
    if (newSystemState.loadingIndicatorMode == LoadingIndicatorMode.stop) {
      emit(newSystemState);
    }
  }

  Future<void> _changeLanguage(ChangeLanguageEvent event, Emitter emit) async {
    logger.i('event = $event');
    emit(SystemState.startLoading(state));

    final localeService = getLocaleService();
    if (localeService.localeToLanguageStr(state.locale) != event.language) {
      localeService.setLocale(event.language);
      emit(
        SystemState.changeLanguage(state, localeService.languageToLocale(event.language)),
      );
    }
    else {
      logger.d('Nothing is done as no change in locale');
    }

    await Future.delayed(const Duration(milliseconds: 500));
    emit(SystemState.stopLoading(state));
  }

  Future<void> _changeTheme(ChangeThemeEvent event, Emitter emit) async {
    logger.i('event = $event');
    if (state.themeMode != event.mode) {
      getThemeService().changeTheme(event.mode);
      emit(
        SystemState.changeTheme(state, event.mode),
      );
    }
  }

  Future<void> _showToast(ShowToastEvent event, Emitter emit) async {
    logger.d('state = $state');
    List<Toast> toastList = [];
    for (Toast toast in state.toast) {
      toast.isNew = false;
      toastList.add(toast);
    }
    toastList.add(Toast(event.message, type: event.type, autoDismissMills: event.autoDismissMillis));

    emit(
      SystemState.changeToast(state, toastList),
    );

  }

  Future<void> _hideToast(HideToastEvent event, Emitter emit) async {
    final notificationState = state;
    if (notificationState.toast.contains(event.toast)) {
      notificationState.toast.remove(event.toast);
      logger.i('event = $event, numOfToast = ${notificationState.toast.length}');
      emit(
        SystemState.changeToast(state, notificationState.toast),
      );
    }
  }

  Future<void> _markDirty(MarkDirtyEvent event, Emitter emit) async {
    if (!state.dirty) {
      emit(
        SystemState.markDirty(state),
      );
    }
  }

  Future<void> _markClean(MarkCleanEvent event, Emitter emit) async {
    if (state.dirty) {
      emit(
        SystemState.markClean(state),
      );
    }
  }

  Future<void> _changeSite(ChangeSiteEvent event, Emitter emit) async {
    if (state.siteCode != event.siteCode) {
      emit(
        SystemState.changeSite(state, event.siteCode),
      );
    }
  }

}

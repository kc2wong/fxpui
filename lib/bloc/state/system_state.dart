import 'dart:math';

import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';

import '../../model/authentication.dart';
import '../../model/system.dart';

@immutable
mixin ActionState {

}

mixin ActionStartState implements ActionState {

}

mixin ActionSuccessState implements ActionState {
  get executionTime;
}

mixin ActionSuccessWithNotificationState implements ActionSuccessState {
  get message;
}

enum LoadingIndicatorMode {
  start,
  stop,
  noChange,
}

class SystemState {
  final Locale locale;
  final ThemeMode themeMode;
  final List<User> localUsers;

  late final int _loadingCount;
  final LoadingIndicatorMode loadingIndicatorMode;
  late final List<Toast> toast;

  late final bool dirty;
  final String? siteCode;

  SystemState({
    required this.locale,
    required this.themeMode,
    required this.localUsers,
    this.loadingIndicatorMode = LoadingIndicatorMode.noChange,
    List<Toast>? toast,
    this.siteCode,
  }) {
    _loadingCount = 0;
    dirty = false;
    this.toast = toast != null ? List.from(toast) : [];
  }

  SystemState.startLoading(SystemState currentState)
      : locale = currentState.locale,
        themeMode = currentState.themeMode,
        localUsers = currentState.localUsers,
        _loadingCount = currentState._loadingCount + 1,
        dirty = currentState.dirty,
        loadingIndicatorMode = currentState._loadingCount == 0 ? LoadingIndicatorMode.start : LoadingIndicatorMode.noChange,
        toast = currentState.toast,
        siteCode = currentState.siteCode;

  SystemState.stopLoading(SystemState currentState)
      : locale = currentState.locale,
        themeMode = currentState.themeMode,
        localUsers = currentState.localUsers,
        _loadingCount = max(0, currentState._loadingCount - 1),
        dirty = currentState.dirty,
        loadingIndicatorMode = currentState._loadingCount == 1 ? LoadingIndicatorMode.stop : LoadingIndicatorMode.noChange,
        toast = currentState.toast,
        siteCode = currentState.siteCode;

  SystemState.changeToast(SystemState currentState, this.toast)
      : locale = currentState.locale,
        themeMode = currentState.themeMode,
        localUsers = currentState.localUsers,
        _loadingCount = currentState._loadingCount,
        dirty = currentState.dirty,
        loadingIndicatorMode = LoadingIndicatorMode.noChange,
        siteCode = currentState.siteCode;

  SystemState.markDirty(SystemState currentState)
      : locale = currentState.locale,
        themeMode = currentState.themeMode,
        localUsers = currentState.localUsers,
        _loadingCount = currentState._loadingCount,
        toast = currentState.toast,
        dirty = true,
        loadingIndicatorMode = LoadingIndicatorMode.noChange,
        siteCode = currentState.siteCode;

  SystemState.markClean(SystemState currentState)
      : locale = currentState.locale,
        themeMode = currentState.themeMode,
        localUsers = currentState.localUsers,
        _loadingCount = currentState._loadingCount,
        toast = currentState.toast,
        dirty = false,
        loadingIndicatorMode = LoadingIndicatorMode.noChange,
        siteCode = currentState.siteCode;

  SystemState.changeLanguage(SystemState currentState, this.locale)
      : themeMode = currentState.themeMode,
        localUsers = currentState.localUsers,
        _loadingCount = currentState._loadingCount,
        dirty = currentState.dirty,
        loadingIndicatorMode = LoadingIndicatorMode.noChange,
        toast = currentState.toast,
        siteCode = currentState.siteCode;

  SystemState.changeTheme(SystemState currentState, this.themeMode)
      : locale = currentState.locale,
        localUsers = currentState.localUsers,
        _loadingCount = currentState._loadingCount,
        dirty = currentState.dirty,
        loadingIndicatorMode = LoadingIndicatorMode.noChange,
        toast = currentState.toast,
        siteCode = currentState.siteCode;

  SystemState.changeSite(SystemState currentState, this.siteCode)
      : themeMode = currentState.themeMode,
        locale = currentState.locale,
        localUsers = currentState.localUsers,
        _loadingCount = currentState._loadingCount,
        dirty = currentState.dirty,
        loadingIndicatorMode = LoadingIndicatorMode.noChange,
        toast = currentState.toast;

  bool isLoading() => _loadingCount > 0;

  ThemeData themeData() => OneContext().theme;
}

import 'package:flutter/material.dart';

import '../../model/system.dart';

class SystemEvent {}

class ChangeLanguageEvent extends SystemEvent {
  final String language;
  ChangeLanguageEvent(this.language);
}

class ChangeThemeEvent extends SystemEvent {
  ThemeMode mode;
  ChangeThemeEvent(this.mode);
}

class StartLoadingEvent extends SystemEvent {
  Color? spinnerColor;

  StartLoadingEvent({
    this.spinnerColor,
  });
}

class MarkDirtyEvent extends SystemEvent {
}

class MarkCleanEvent extends SystemEvent {
}

class StopLoadingEvent extends SystemEvent {
}

class ShowToastEvent extends SystemEvent {
  final String message;
  final ToastType type;
  final int? autoDismissMillis;
  ShowToastEvent(this.message, this.type, this.autoDismissMillis);
}

class HideToastEvent extends SystemEvent {
  final Toast toast;
  HideToastEvent(this.toast);
}

class ChangeSiteEvent extends SystemEvent {
  final String? siteCode;
  ChangeSiteEvent(this.siteCode);
}

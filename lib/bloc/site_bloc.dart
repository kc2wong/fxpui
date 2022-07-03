import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/exception.dart';
import '../service/site.dart';
import '../util/logger.dart';
import 'event/site_event.dart';
import 'state/site_state.dart';

class SiteSearchBloc extends Bloc<BaseSiteEvent, SiteSearchState> {
  final SiteSearchService _siteService;

  SiteSearchBloc(this._siteService)
      : super(
          SiteSearchState.initial(),
        ) {
    on<SiteSearchEvent>(_handleSiteSearchEvent);
    on<SiteSelectEvent>(_handleSiteSelectEvent);
    on<DisableSelectSiteEvent>(_handleDisableSelectSiteEvent);
    on<EnableSelectSiteEvent>(_handleEnableSelectSiteEvent);
  }

  void resetState() {
    add(
      SiteSearchEvent(true),
    );
  }

  void listSite() {
    add(
      SiteSearchEvent(false),
    );
  }

  void selectSite(String siteCode) {
    add(
      SiteSelectEvent(siteCode),
    );
  }

  void disableSelectSite() {
    add(
      DisableSelectSiteEvent(),
    );
  }

  void enableSelectSite() {
    add(
      EnableSelectSiteEvent(),
    );
  }

  Future<void> _handleSiteSearchEvent(SiteSearchEvent event, Emitter emit) async {
    logger.i('event = $event');

    if (event.reset) {
      emit(SiteSearchState.initial());
    } else {
      try {
        emit(SiteSearchState.startSearch(state));
        final searchResult = await _siteService.listSite();
        searchResult.sort((c1, c2) => c1.siteCode.compareTo(c2.siteCode));

        // await Future.delayed(const Duration(seconds: 1));

        emit(SiteSearchState.finishSearch(
          state,
          searchResult,
          DateTime.now().microsecondsSinceEpoch,
        ));
      } on ApplicationException catch (ae) {
        emit(SiteSearchState.failSearch(
          state,
          ae.errorCode,
          ae.errorParams,
          DateTime.now().microsecondsSinceEpoch,
        ));
      } catch (error) {
        emit(SiteSearchState.failSearch(
          state,
          genericErrorCode,
          [],
          DateTime.now().microsecondsSinceEpoch,
        ));
      }
    }
  }

  Future<void> _handleSiteSelectEvent(SiteSelectEvent event, Emitter emit) async {
    final matchedSite = (state.siteList ?? []).where((element) => element.siteCode == event.siteCode);
    if (matchedSite.isNotEmpty) {
      logger.i('matchedSite = ${matchedSite.first.siteCode}');
      emit(SiteSearchState.selectSite(
        state,
        matchedSite.first,
      ));
    }
  }

  Future<void> _handleEnableSelectSiteEvent(EnableSelectSiteEvent event, Emitter emit) async {
    logger.i('event = $event');
    if (!state.siteSelectable) {
      emit(SiteSearchState(
        loading: state.loading,
        siteSelectable: true,
        selectedSite: state.selectedSite,
        siteList: state.siteList,
        errorCode: state.errorCode,
        errorParams: state.errorParams,
        lastActionTime: state.lastActionTime,
      ));
    }
  }

  Future<void> _handleDisableSelectSiteEvent(DisableSelectSiteEvent event, Emitter emit) async {
    logger.i('event = $event');
    if (state.siteSelectable) {
      emit(SiteSearchState(
        loading: state.loading,
        siteSelectable: false,
        selectedSite: state.selectedSite,
        siteList: state.siteList,
        errorCode: state.errorCode,
        errorParams: state.errorParams,
        lastActionTime: state.lastActionTime,
      ));
    }
  }

}

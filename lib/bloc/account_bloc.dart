import 'package:flutter_bloc/flutter_bloc.dart';

import '../service/account.dart';
import '../model/exception.dart';
import '../model/client.dart';
import '../util/logger.dart';
import 'event/account_event.dart';
import 'state/account_state.dart';

class FxAccountSearchBloc extends Bloc<BaseFxAccountEvent, FxAccountSearchState> {
  final FxAccountSearchService _fxAccountSearchService;

  FxAccountSearchBloc(this._fxAccountSearchService)
      : super(
          FxAccountSearchState.initialize(),
        ) {
    on<FxAccountSearchEvent>(_handleFxAccountSearchEvent);
    on<FxAccountSelectEvent>(_handleFxAccountSelectEvent);
  }

  bool withData() => state.lastActionTime > 0;

  void resetState() {
    add(
      FxAccountSearchEvent('', ''),
    );
  }

  void searchFxAccount({
    String? extAccountRef1,
    String? extAccountRef2,
  }) {
    add(
      FxAccountSearchEvent(
        extAccountRef1 ?? '',
        extAccountRef2 ?? '',
      ),
    );
  }

  void selectFxAccount(FxAccount fxAccount) {
    add(
      FxAccountSelectEvent(fxAccount),
    );
  }

  void unSelectFxAccount() {
    add(
      FxAccountSelectEvent(null),
    );
  }

  Future<void> _handleFxAccountSearchEvent(FxAccountSearchEvent event, Emitter emit) async {
    logger.i('event = $event, extAccountRef1 = ${event.extAccountRef1} extAccountRef2 = ${event.extAccountRef2}');

    if (event.extAccountRef1.isEmpty && event.extAccountRef2.isEmpty) {
      // reset
      emit(FxAccountSearchState(
        extAccountRefList: null,
        accountList: null,
        loading: false,
        errorCode: null,
        errorParams: [],
        lastActionTime: DateTime.now().microsecondsSinceEpoch,
        selectedFxAccount: null,
      ));
      return;
    }

    // Normal Search
    List<FxAccount?>? newFxAccountList;
    if (state.extAccountRefList != null && state.accountList != null) {
      if (event.extAccountRef1.isEmpty && event.extAccountRef2.isEmpty) {
        newFxAccountList = [null, null];
      }
      else if (event.extAccountRef1.isEmpty && event.extAccountRef2 == state.extAccountRefList![1]) {
        newFxAccountList = [null, state.accountList![1]];
      }
      else if (event.extAccountRef2.isEmpty && event.extAccountRef1 == state.extAccountRefList![0]) {
        newFxAccountList = [state.accountList![0], null];
      }
    }

    if (newFxAccountList != null) {
      emit(FxAccountSearchState.finishSearch(state, newFxAccountList));
    }
    else {
      emit(FxAccountSearchState.startSearch(
        state,
        [event.extAccountRef1, event.extAccountRef2],
      ));

      try {
        final searchResult = await _fxAccountSearchService.getFxAccounts(
          extAccountRef1: event.extAccountRef1,
          extAccountRef2: event.extAccountRef2,
        );

        List<FxAccount?> rtn = [
          event.extAccountRef1.isNotEmpty && searchResult.isNotEmpty ? searchResult[0] : null,
          event.extAccountRef2.isNotEmpty && searchResult.length >= 2 ? searchResult[1] : null,
        ];
        logger.d('accountList = $rtn');
        emit(FxAccountSearchState.finishSearch(state, rtn));
      } on ApplicationException catch (ae) {
        emit(
          FxAccountSearchState.failSearch(
            state,
            ae.errorCode,
            ae.errorParams,
          ),
        );
      } catch (error) {
        emit(
          FxAccountSearchState.failSearch(
            state,
            genericErrorCode,
            [],
          ),
        );
      }
    }
  }

  Future<void> _handleFxAccountSelectEvent(FxAccountSelectEvent event, Emitter emit) async {
    logger.i('event = $event, selectedFxAccount = ${event.selectedFxAccount}');

    emit(
      FxAccountSearchState(
        extAccountRefList: state.extAccountRefList,
        accountList: state.accountList,
        loading: state.loading,
        errorCode: state.errorCode,
        errorParams: state.errorParams,
        lastActionTime: state.lastActionTime,
        selectedFxAccount: event.selectedFxAccount,
      ),
    );
  }
}

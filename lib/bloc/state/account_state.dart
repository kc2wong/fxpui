import '../../model/client.dart';

class FxAccountSearchState {
  // Search criteria
  final List<String>? extAccountRefList;

  final bool loading;
  final List<FxAccount?>? accountList;
  final String? errorCode;
  final List<String>? errorParams;
  final FxAccount? selectedFxAccount;
  final int lastActionTime;

  FxAccountSearchState({
    this.extAccountRefList,
    this.accountList,
    required this.loading,
    this.errorCode,
    this.errorParams,
    required this.lastActionTime,
    this.selectedFxAccount,
  });

  FxAccountSearchState.initialize()
      : extAccountRefList = null,
        loading = false,
        accountList = null,
        errorCode = null,
        errorParams = [],
        selectedFxAccount = null,
        lastActionTime = 0;

  FxAccountSearchState.startSearch(
    FxAccountSearchState state,
    this.extAccountRefList,
  )   : loading = true,
        accountList = state.accountList,
        errorCode = state.errorCode,
        errorParams = state.errorParams,
        selectedFxAccount = null,
        lastActionTime = state.lastActionTime;

  FxAccountSearchState.finishSearch(
    FxAccountSearchState state,
    this.accountList,
  )   : extAccountRefList = state.extAccountRefList,
        loading = false,
        errorCode = null,
        errorParams = [],
        selectedFxAccount = null,
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

  FxAccountSearchState.failSearch(
    FxAccountSearchState state,
    this.errorCode,
    this.errorParams,
  )   : extAccountRefList = state.extAccountRefList,
        loading = false,
        accountList = [],
        selectedFxAccount = null,
        lastActionTime = DateTime.now().microsecondsSinceEpoch;
}

import '../../model/site.dart';

class SiteSearchState {
  final bool loading;
  final bool siteSelectable;
  final Site? selectedSite;
  final List<Site>? siteList;
  final String? errorCode;
  final List<String> errorParams;
  final int lastActionTime;

  SiteSearchState({
    required this.loading,
    required this.siteSelectable,
    this.selectedSite,
    this.siteList,
    this.errorCode,
    required this.errorParams,
    required this.lastActionTime,
  });

  SiteSearchState.initial()
      : loading = false,
        siteSelectable = true,
        siteList = null,
        selectedSite = null,
        errorCode = null,
        errorParams = [],
        lastActionTime = 0;

  SiteSearchState.startSearch(SiteSearchState currentState)
      : loading = true,
        siteSelectable = currentState.siteSelectable,
        siteList = currentState.siteList,
        selectedSite = currentState.selectedSite,
        errorCode = null,
        errorParams = [],
        lastActionTime = currentState.lastActionTime;

  SiteSearchState.finishSearch(SiteSearchState currentState, this.siteList, this.lastActionTime)
      : loading = false,
        selectedSite = currentState.selectedSite ?? _firstSite(siteList),
        siteSelectable = currentState.siteSelectable,
        errorCode = null,
        errorParams = [];

  SiteSearchState.failSearch(SiteSearchState currentState, this.errorCode, this.errorParams, this.lastActionTime)
      : loading = false,
        siteSelectable = currentState.siteSelectable,
        siteList = currentState.siteList,
        selectedSite = currentState.selectedSite;

  SiteSearchState.selectSite(SiteSearchState currentState, this.selectedSite)
      : loading = true,
        siteSelectable = currentState.siteSelectable,
        siteList = currentState.siteList,
        errorCode = null,
        errorParams = [],
        lastActionTime = currentState.lastActionTime;
}

Site? _firstSite(List<Site>? siteList) {
  if (siteList == null || siteList.isEmpty) {
    return null;
  }
  return siteList.first;
}

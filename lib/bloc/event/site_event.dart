abstract class BaseSiteEvent {
}

class SiteSearchEvent extends BaseSiteEvent {
  bool reset;

  SiteSearchEvent(this.reset);
}

class SiteSelectEvent extends BaseSiteEvent {
  String siteCode;

  SiteSelectEvent(this.siteCode);
}

class DisableSelectSiteEvent extends BaseSiteEvent {
}

class EnableSelectSiteEvent extends BaseSiteEvent {
}

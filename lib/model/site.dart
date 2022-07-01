class Site {
  final String siteCode;

  Site(
    this.siteCode,
  );

  Site.fromJson(Map<String, dynamic> json) : siteCode = json['siteCode'] as String;
}

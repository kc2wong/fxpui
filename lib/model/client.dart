

class ExternalAccountRef {
  final String refType;
  final String ref;
  final String? name;

  ExternalAccountRef({
    required this.refType,
    required this.ref,
    this.name,
  });

  ExternalAccountRef.fromJson(Map<String, dynamic> json)
      : ref = json['ref'],
        refType = json['type'],
        name = json['name'];
}

class FxAccount {
  late final String clientId;
  late final String accountRef;
  late final String name;
  late final String? alertMessage;
  late final List<ExternalAccountRef> externalAccount;

  FxAccount({
    required this.clientId,
    required this.accountRef,
    required this.name,
    this.alertMessage,
    required this.externalAccount,
  });

  FxAccount.fromJson(Map<String, dynamic> json, String extAccountRef) {
    clientId = json['fxAccountId'];
    accountRef = json['accountRef'];
    name = json['name'];
    alertMessage = json['alertMessage'];

    final fallbackExtRef = ExternalAccountRef(refType: '', ref: extAccountRef);
    if (!json.containsKey('externalAccounts')) {
      externalAccount = [fallbackExtRef];
    }
    else {
      final baseList = (json['externalAccounts'] as List<dynamic>).map((e) => ExternalAccountRef.fromJson(e)).toList(growable: false);
      externalAccount = baseList;
    }
  }
}

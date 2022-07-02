enum EnrichmentRequestStatus {
  initial,
  started,
  submitted,
  pendingFxt,
  pendingApproval,
  paired,
  failed,
  cancelled,
  rejected,
}

enum PaymentDirection {
  outgoing,
  incoming,
}

class DraftPayment {

  final int numOfAccountRequired;
  final String? accountRef1;
  final String? accountRef2;
  final PaymentDirection? direction;
  final String? creditCcy;
  final double? creditAmount;
  final String? debitCcy;
  final double? debitAmount;
  final String? paymentRef;
  final String? paymentRefType;
  final DateTime? executeDate;
  final String? fxRef;

  final String? creditAmountError;
  final String? debitAmountError;

  DraftPayment({
    this.numOfAccountRequired = 0,
    this.accountRef1,
    this.accountRef2,
    this.direction,
    this.creditCcy,
    this.creditAmount,
    this.debitCcy,
    this.debitAmount,
    this.paymentRefType,
    this.paymentRef,
    this.executeDate,
    this.fxRef,
    this.creditAmountError,
    this.debitAmountError,
  });

  DraftPayment.withValidationFailure(
    DraftPayment current, {
    this.creditAmountError,
    this.debitAmountError,
  })  : numOfAccountRequired = current.numOfAccountRequired,
        accountRef1 = current.accountRef1,
        accountRef2 = current.accountRef2,
        direction = current.direction,
        creditCcy = current.creditCcy,
        creditAmount = current.creditAmount,
        debitCcy = current.debitCcy,
        debitAmount = current.debitAmount,
        paymentRefType = current.paymentRefType,
        paymentRef = current.paymentRef,
        executeDate = current.executeDate,
        fxRef = current.fxRef;

  bool canStart() {
    return accountRef1 != null &&
        (numOfAccountRequired < 2 || accountRef2 != null) &&
        direction != null &&
        creditCcy != null &&
        debitCcy != null &&
        (creditCcy != debitCcy) &&
        (creditAmount != null || debitAmount != null);
  }
}

class Payment {
  final String siteCode;
  final String? paymentRef;
  final String? paymentRefType;

  final List<String> accountRefs;

  final PaymentDirection direction;

  final String creditCcy;
  final double? creditAmount;

  final String debitCcy;
  final double? debitAmount;

  final DateTime executeDate;

  Payment({
    required this.siteCode,
    this.paymentRefType,
    this.paymentRef,
    this.accountRefs = const [],
    required this.direction,
    required this.creditCcy,
    this.creditAmount,
    required this.debitCcy,
    this.debitAmount,
    required this.executeDate,
  });

  Payment.fromExistingWithDelta(
    Payment existing, {
    required this.siteCode,
    required this.accountRefs,
    required this.direction,
    required this.creditCcy,
    this.creditAmount,
    required this.debitCcy,
    this.debitAmount,
  })  : paymentRef = existing.paymentRef,
        paymentRefType = existing.paymentRefType,
        executeDate = existing.executeDate;

  Payment.fromJson(Map<String, dynamic> json)
      : siteCode = json['siteCode'] as String,
        paymentRef = json['paymentRef'] as String,
        paymentRefType = json['paymentRefType'] as String,
        accountRefs = json['accountRefs'].cast<String>(),
        direction = PaymentDirection.values.firstWhere((element) => element.name == json['direction']),
        creditCcy = json['creditCcy'] as String,
        debitCcy = json['debitCcy'] as String,
        creditAmount = json.containsKey('creditAmount') ? (json['creditAmount'] as num).toDouble() : null,
        debitAmount = json.containsKey('debitAmount') ? (json['debitAmount'] as num).toDouble() : null,
        executeDate = DateTime.parse(json['execDate']);
}

class Memo {
  late String createdBy;
  late DateTime createdTime;
  late String content;

  Memo.fromJson(Map<String, dynamic> json)
      : createdBy = json['createdBy'] as String,
        createdTime = DateTime.parse(json['createdTime']),
        content = json['content'] as String
  ;
}

class EnrichmentRequest {
  final String id;
  final Payment payment;
  final EnrichmentRequestStatus status;

  final DateTime? valueDate;
  final String? initiatedBy;

  final String? ccyPair;
  final double? rate;
  final String? product;

  final String? fxRef;
  final String? fxd;
  final String? fxt;

  final List<String> failureMessages;
  final List<Memo> memos;

  EnrichmentRequest({
    required this.id,
    required this.payment,
    required this.status,
    this.valueDate,
    this.initiatedBy,
    this.ccyPair,
    this.rate,
    this.product,
    this.fxRef,
    this.fxd,
    this.fxt,
    this.failureMessages = const [],
    this.memos = const [],
  });

  EnrichmentRequest.fromExisting(
    EnrichmentRequest existing, {
    Payment? payment,
    EnrichmentRequestStatus? status,
    DateTime? valueDate,
    String? initiatedBy,
    String? ccyPair,
    double? rate,
    String? product,
    String? fxRef,
    String? fxd,
    String? fxt,
    List<String>? failureMessages,
    List<Memo>? memos,
  })  : id = existing.id,
        payment = payment ?? existing.payment,
        status = status ?? existing.status,
        valueDate = valueDate ?? existing.valueDate,
        initiatedBy = initiatedBy ?? existing.initiatedBy,
        ccyPair = ccyPair ?? existing.ccyPair,
        rate = rate ?? existing.rate,
        product = product ?? existing.product,
        fxRef = fxRef ?? existing.fxRef,
        fxd = fxd ?? existing.fxd,
        fxt = fxt ?? existing.fxt,
        failureMessages = failureMessages ?? existing.failureMessages,
        memos = memos ?? existing.memos;

  EnrichmentRequest.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        payment = Payment.fromJson(json['payment'] as Map<String, dynamic>),
        status = EnrichmentRequestStatus.values.firstWhere((element) => element.name == json['status']),
        valueDate = DateTime.tryParse(json['valueDate']),
        initiatedBy = json['initiatedBy'] as String,
        ccyPair = json['ccyPair'] as String,
        product = json['product'] as String?,
        rate = json.containsKey('rate') ? (json['rate'] as num).toDouble() : null,
        fxRef = json['fxRef'] as String?,
        fxd = json['fxd'] as String?,
        fxt = json['fxt'] as String?,
        failureMessages = json.containsKey('failureMessages')
            ? (json['failureMessages'] as List<dynamic>).map((e) => e as String).toList(
                  growable: false,
                )
            : [],
        memos =
            json.containsKey('memos') ? (json['memos'] as List<dynamic>).map((e) => Memo.fromJson(e)).toList(growable: false) : [];
}

class AutoQuoteInfo {
  String productCode;
  String productName;
  DateTime? defaultValueDate;
  bool allowNullValueDate;

  AutoQuoteInfo({
    required this.productCode,
    required this.productName,
    this.defaultValueDate,
    required this.allowNullValueDate,
  });
}

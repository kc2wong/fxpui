class Currency {
  final String isoCcy;
  final int precision;

  Currency(
    this.isoCcy,
    this.precision,
  );

  Currency.fromJson(Map<String, dynamic> json)
      : isoCcy = json['isoCcy'] as String,
        precision = json['precision'] as int;
}

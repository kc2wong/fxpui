
const String genericErrorCode = 'SYSTEM_ERROR';

class ApplicationException implements Exception {
  final String errorCode;
  final List<String> errorParams;

  const ApplicationException({
    required this.errorCode,
    this.errorParams = const [],
  });
}

class ValidationException extends ApplicationException {
  ValidationException({
    required errorCode,
    errorParam = const [],
  }) : super(errorCode: errorCode, errorParams: errorParam);
}

class SystemException extends ApplicationException {
  SystemException({
    required errorCode,
    errorParam = const [],
  }) : super(errorCode: errorCode, errorParams: errorParam);
}

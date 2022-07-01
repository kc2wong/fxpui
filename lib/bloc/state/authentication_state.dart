import '../../model/authentication.dart';

class AuthenticationState {
  final Authentication? authentication;
  final String? errorCode;

  AuthenticationState({
    this.authentication,
    this.errorCode,
  });
}

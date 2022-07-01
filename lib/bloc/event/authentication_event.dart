abstract class AuthenticationEvent {}

class LogoutEvent extends AuthenticationEvent {}

class LoginEvent extends AuthenticationEvent {
  final String userid;

  LoginEvent({
    required this.userid,
  });
}

import 'package:flutter_bloc/flutter_bloc.dart';

import './event/authentication_event.dart';
import './state/authentication_state.dart';
import '../model/authentication.dart';
import '../model/exception.dart';
import '../service/authentication.dart';
import '../util/logger.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationService authenticationService;

  AuthenticationBloc({required this.authenticationService, Authentication? authentication})
      : super(AuthenticationState(authentication: authentication, errorCode: null)) {
    on<LoginEvent>(_login);
    on<LogoutEvent>(_logout);
  }

  Future<void> _login(LoginEvent event, Emitter emit) async {
    logger.i('event = $event, authentication = ${state.authentication}');

    try {
      final authentication = await authenticationService.login(event.userid);
      emit(AuthenticationState(authentication: authentication, errorCode: null));
    } on ApplicationException catch (ae) {
      emit(AuthenticationState(authentication: null, errorCode: ae.errorCode));
    } catch (error) {
      emit(AuthenticationState(authentication: null, errorCode: genericErrorCode));
    }
  }

  Future<void> _logout(LogoutEvent event, Emitter emit) async {
    logger.i('event = $event, authentication = ${state.authentication}');
    await authenticationService.logout();
    emit(AuthenticationState(authentication: null, errorCode: null));
  }
}

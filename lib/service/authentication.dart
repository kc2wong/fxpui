import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'common.dart';
import '../model/authentication.dart';
import '../model/exception.dart';
import '../util/logger.dart';

class AuthenticationService extends BaseHttpService {

  Future<List<User>> getLocalUsers() async {
    return [
      User('HKGINPUTTER', 'hkginputter@bnpp.com', 'HKGINPUTTER', [], group: 'APAC'),
      User('HKGAPPROVER', 'hkgapprover@bnpp.com', 'HKGAPPROVER', [], group: 'APAC'),
      User('SGPINPUTTER', 'sgpinputter@bnpp.com', 'SGPINPUTTER', [], group: 'APAC'),
      User('SGPAPPROVER', 'sgpapprover@bnpp.com', 'SGPAPPROVER', [], group: 'APAC'),
    ];
  }

  Future<Authentication?> getAuthentication() async {
    // Retrieve from local storage
    return null;
  }

  Future<Authentication> login(String userid) async {
    const url = '${BaseHttpService.baseUrl}/v1/authentications';
    final request = json.encode(
      {
        'userid': userid.trim(),
      },
    );
    logger.d('login request = $request');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: request
    );
    logger.d('login response statusCode = ${response.statusCode}, body = ${response.body}');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final token = jsonResponse['token'];
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final user = User.fromJson(userid, decodedToken);
      return Authentication(token, user);
    } else if (response.statusCode == 400) {
      logger.i('Invalid userid');
      throw ValidationException(errorCode: _getErrorCode(response.body));
    } else {
      logger.w('Unknown error in authenticating user');
      throw SystemException(errorCode: _getErrorCode(response.body));
    }
  }

  Future<void> logout() async {
    // delete token from local storage
    return;
  }

  String _getErrorCode(String responseBody) {
    final jsonResponse = json.decode(responseBody);
    return jsonResponse.containsKey('errorCode') ? jsonResponse['errorCode'] : genericErrorCode;
  }
}


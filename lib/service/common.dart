import 'dart:convert';

import '../model/exception.dart';

abstract class BaseHttpService {
  static const baseUrl = 'https://demo8048542.mockable.io';

  String getErrorCode(String responseBody) {
    final jsonResponse = json.decode(responseBody);
    return jsonResponse.containsKey('errorCode') ? jsonResponse['errorCode'] : genericErrorCode;
  }
}
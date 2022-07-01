import 'dart:convert';

import 'package:http/http.dart' as http;

import 'common.dart';
import '../model/currency.dart';
import '../model/exception.dart';
import '../util/logger.dart';

class CurrencySearchService extends BaseHttpService {
  Future<List<Currency>> listCurrency() async {

    const url =
        '${BaseHttpService.baseUrl}/v1/currencies';
    final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
    );
    logger.d('listCurrency response statusCode = ${response.statusCode}');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as List<dynamic>;
      return jsonResponse.map((e) => Currency.fromJson(e)).toList(growable: false);
    } else {
      logger.w('Unknown error in list currency');
      throw SystemException(errorCode: getErrorCode(response.body));
    }
  }
}


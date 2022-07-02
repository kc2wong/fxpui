import 'dart:convert';

import 'package:http/http.dart' as http;

import 'common.dart';
import '../model/exception.dart';
import '../model/client.dart';
import '../util/logger.dart';

class FxAccountSearchService extends BaseHttpService {
  Future<List<FxAccount>> getFxAccounts({
    String? extAccountRef1,
    String? extAccountRef2,
  }) async {
    final url = '${BaseHttpService.baseUrl}/v1/accounts?extAccountRef1=$extAccountRef1';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as List<dynamic>;
      final extAccountRefList = [extAccountRef2, extAccountRef1];
      final accountList = jsonResponse.map((e) => FxAccount.fromJson(e, extAccountRefList.removeLast()!)).toList(growable: false);
      return accountList;
    } else {
      logger.w('Unknown error in getting fxAccounts');
      throw SystemException(errorCode: getErrorCode(response.body));
    }
  }
}

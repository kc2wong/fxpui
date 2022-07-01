import 'dart:convert';

import 'package:http/http.dart' as http;

import 'common.dart';
import '../model/site.dart';
import '../model/exception.dart';
import '../util/logger.dart';

class SiteSearchService extends BaseHttpService {
  Future<List<Site>> listSite() async {

    const url =
        '${BaseHttpService.baseUrl}/v1/sites';
    final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
    );
    logger.d('listSite response statusCode = ${response.statusCode}');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as List<dynamic>;
      return jsonResponse.map((e) => Site.fromJson(e)).toList(growable: false);
    } else {
      logger.w('Unknown error in list site');
      throw SystemException(errorCode: getErrorCode(response.body));
    }
  }
}


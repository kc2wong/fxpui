import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/common.dart';
import '../model/exception.dart';
import '../model/payment.dart';
import '../util/logger.dart';
import 'common.dart';

class PaymentSearchService extends BaseHttpService {
  Future<SearchResult<EnrichmentRequest>> searchEnrichmentRequest({
    // Search criteria
    String? siteCode,
    List<EnrichmentRequestStatus>? enrichmentRequestStatus = const [],
    String? instructionId,
    String? account,
    DateTime? executionDateFrom,
    DateTime? executionDateTo,
    String? initiatedBy,
    String? creditCcy,
    double? creditAmountFrom,
    double? creditAmountTo,
    String? debitCcy,
    double? debitAmountFrom,
    double? debitAmountTo,
    required int offSet,
    required int pageSize,
  }) async {
    logger.d('search with siteCode = $siteCode');
    const url =
        '${BaseHttpService.baseUrl}/v1/payments';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    logger.d('listPayments response statusCode = ${response.statusCode}');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final offset = jsonResponse['offset'] as int;
      final pageSize = jsonResponse['pageSize'] as int;
      final startIndex = jsonResponse['startIndex'] as int;
      final endIndex = jsonResponse['endIndex'] as int;
      final totalRecords = jsonResponse['totalRecords'] as int;
      final elements = jsonResponse['elements'] as List<dynamic>;
      final enrichmentRequests = elements.map((e) => EnrichmentRequest.fromJson(e)).toList(growable: false);
      return SearchResult<EnrichmentRequest>(offSet: offset, startIndex: startIndex, endIndex: endIndex, totalRecords: totalRecords, elements: enrichmentRequests, pageSize: pageSize);
    } else {
      logger.w('Error in list payments');
      throw SystemException(errorCode: getErrorCode(response.body));
    }
  }

  Future<EnrichmentRequest> createPayment(Payment payment, String? fxRef) async {
    logger.d('create with siteCode = ${payment.siteCode}');
    const url =
        '${BaseHttpService.baseUrl}/v1/payments';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    logger.d('createEnrichmentRequest response statusCode = ${response.statusCode}');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return EnrichmentRequest.fromJson(jsonResponse);
    } else {
      logger.i('Error in create payment, errorCode = ${getErrorCode(response.body)}');
      throw ApplicationException(errorCode: getErrorCode(response.body));
    }
  }

}

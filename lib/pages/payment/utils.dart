import 'package:flutter/material.dart';

import '../../model/payment.dart';

const numberOfInputAccount = 1;

final _enrichmentStatusColorMap = {
  EnrichmentRequestStatus.initial: Colors.grey.shade200,
  EnrichmentRequestStatus.started: Colors.yellow.shade200,
  EnrichmentRequestStatus.paired: Colors.green.shade100,
  EnrichmentRequestStatus.failed: Colors.red.shade200,
};

Color getEnrichmentRequestStatusColor(EnrichmentRequestStatus? status) => _enrichmentStatusColorMap[status] ?? Colors.grey.shade200;

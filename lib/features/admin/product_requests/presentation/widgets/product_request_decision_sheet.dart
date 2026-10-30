import 'package:flutter/material.dart';

import '../../../common/admin_common.dart';
import '../../domain/entities/admin_product_request.dart';

typedef ProductRequestChoice = ({
  ProductRequestDecision decision,
  String reason,
});

/// Order of options in the "Product request decision" sheet.
const productRequestDecisions = ProductRequestDecision.values;

/// Opens the "Product request decision" sheet for [request].
Future<ProductRequestChoice?> showProductRequestDecisionSheet(
  BuildContext context, {
  required ProductRequestDetail request,
}) async {
  final summary = request.summary;
  final duplicate = request.duplicateCheck?.isDuplicate ?? false;
  final result = await showAdminDecisionSheet(
    context,
    title: 'Product request decision',
    subtitle: [
      summary.code,
      summary.productName,
      ?request.brand,
      if (summary.packLabel.isNotEmpty) summary.packLabel,
    ].join(' · '),
    initialIndex: productRequestDecisions.indexOf(
      duplicate
          ? ProductRequestDecision.reject
          : ProductRequestDecision.approve,
    ),
    options: [
      AdminDecisionOption(
        label: 'Approve · Create new variant',
        confirmLabel: 'Approve & create variant',
        suggestedReason:
            'Barcode verified. ${summary.packLabel} pack is not yet in the '
            'catalogue.',
      ),
      AdminDecisionOption(
        label: 'Reject request',
        confirmLabel: 'Confirm rejection',
        destructive: true,
        suggestedReason: duplicate
            ? request.duplicateCheck?.message
            : 'Barcode or pack size could not be verified.',
      ),
    ],
  );
  if (result == null) return null;
  return (
    decision: productRequestDecisions[result.optionIndex],
    reason: result.reason,
  );
}

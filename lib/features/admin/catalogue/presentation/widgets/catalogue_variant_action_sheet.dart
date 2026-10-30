import 'package:flutter/material.dart';

import '../../../common/admin_common.dart';
import '../../domain/entities/admin_catalogue_variant.dart';

typedef CatalogueVariantChoice = ({
  CatalogueVariantAction action,
  String reason,
});

/// Order of options in the "Catalogue action" sheet.
const catalogueVariantActions = CatalogueVariantAction.values;

/// Opens the "Catalogue action" sheet for [variant].
Future<CatalogueVariantChoice?> showCatalogueVariantActionSheet(
  BuildContext context, {
  required CatalogueVariantDetail variant,
}) async {
  final summary = variant.summary;
  final result = await showAdminDecisionSheet(
    context,
    title: 'Catalogue action',
    subtitle: [
      summary.skuCode,
      summary.name,
      summary.packLabel,
      if (variant.linkedListings != null)
        '${variant.linkedListings} linked listings',
    ].join(' · '),
    initialIndex: 0,
    options: [
      AdminDecisionOption(
        label: 'Approve details · Keep active',
        confirmLabel: 'Confirm variant approval',
        suggestedReason:
            'Barcode and '
            '${variant.description?.split(' · ').last ?? summary.packLabel} '
            'pack verified. Description is accurate.',
      ),
      const AdminDecisionOption(
        label: 'Deactivate variant',
        confirmLabel: 'Confirm deactivation',
        destructive: true,
        suggestedReason:
            'Variant is no longer sold. Linked listings must move to an '
            'active variant.',
      ),
      const AdminDecisionOption(
        label: 'Mark as duplicate',
        confirmLabel: 'Confirm · Mark duplicate',
        destructive: true,
        suggestedReason:
            'Same barcode and pack size as an existing active variant.',
      ),
    ],
  );
  if (result == null) return null;
  return (
    action: catalogueVariantActions[result.optionIndex],
    reason: result.reason,
  );
}

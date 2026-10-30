import 'package:flutter/material.dart';

import '../../../common/admin_common.dart';
import '../../domain/entities/admin_shop.dart';

typedef ShopStatusChoice = ({AdminShopStatusAction action, String reason});

/// Order of options in the "Change shop status" sheet.
const shopStatusOptions = AdminShopStatusAction.values;

/// Suggested action for a shop's current status.
AdminShopStatusAction? suggestedShopAction(AdminShopStatus status) =>
    switch (status) {
      AdminShopStatus.approved ||
      AdminShopStatus.suspended => AdminShopStatusAction.setLive,
      AdminShopStatus.flagged ||
      AdminShopStatus.live => AdminShopStatusAction.suspend,
      AdminShopStatus.draft ||
      AdminShopStatus.kycReview ||
      AdminShopStatus.paused ||
      AdminShopStatus.closed ||
      AdminShopStatus.unknown => null,
    };

Future<ShopStatusChoice?> showShopStatusSheet(
  BuildContext context, {
  required AdminShop shop,
  AdminShopStatusAction? preset,
  String? initialReason,
}) async {
  preset ??= suggestedShopAction(shop.status);
  final result = await showAdminDecisionSheet(
    context,
    title: 'Change shop status',
    subtitle: '${shop.reference} · ${shop.name}',
    initialIndex: preset == null ? null : shopStatusOptions.indexOf(preset),
    initialReason: initialReason,
    options: [
      AdminDecisionOption(
        label: 'Set live · Make visible',
        confirmLabel: 'Confirm · Set live',
        suggestedReason:
            'KYC approved, catalogue complete and '
            '${shop.areaName ?? 'the area is'} serviceable.',
      ),
      const AdminDecisionOption(
        label: 'Suspend · Hide pending review',
        confirmLabel: 'Confirm · Suspend shop',
        destructive: true,
        suggestedReason:
            'Customer complaints under review. Shop hidden until support '
            'completes the review.',
      ),
      const AdminDecisionOption(
        label: 'Close · Permanent closure',
        confirmLabel: 'Confirm · Close shop',
        destructive: true,
        suggestedReason: 'Owner requested permanent closure of the shop.',
      ),
    ],
  );
  if (result == null) return null;
  return (action: shopStatusOptions[result.optionIndex], reason: result.reason);
}

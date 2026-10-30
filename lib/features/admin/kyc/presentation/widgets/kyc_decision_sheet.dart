import 'package:flutter/material.dart';

import '../../../common/admin_common.dart';
import '../../domain/entities/kyc_applicant.dart';
import 'kyc_labels.dart';

/// Order of options in the KYC decision sheet.
const kycDecisionOptions = [KycDecision.approve, KycDecision.reject];

typedef KycDecisionChoice = ({KycDecision decision, String reason});

/// Opens the approve / reject sheet for [applicant]. [preset] and
/// [initialReason] restore the admin's choice after a failed submit.
Future<KycDecisionChoice?> showKycDecisionSheet(
  BuildContext context, {
  required KycApplicant applicant,
  KycDecision? preset,
  String? initialReason,
}) async {
  final role = applicant.role.label.toLowerCase();
  final result = await showAdminDecisionSheet(
    context,
    title: 'KYC decision',
    subtitle:
        '${applicant.reference} · ${applicant.name} · '
        'CNIC ending ${applicant.cnicLast4}',
    initialIndex: preset == null ? null : kycDecisionOptions.indexOf(preset),
    initialReason: initialReason,
    options: [
      AdminDecisionOption(
        label: 'Approve identity',
        confirmLabel: 'Approve & notify $role',
        suggestedReason:
            'Both sides are clear. Name matches, CNIC is valid and no '
            'duplicate flags found.',
      ),
      AdminDecisionOption(
        label: 'Reject & request resubmission',
        confirmLabel: 'Reject & notify $role',
        destructive: true,
        suggestedReason:
            'CNIC front is blurred. Retake in daylight with all four '
            'corners visible.',
      ),
    ],
  );
  if (result == null) return null;
  return (
    decision: kycDecisionOptions[result.optionIndex],
    reason: result.reason,
  );
}

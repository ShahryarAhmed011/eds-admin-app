import 'package:equatable/equatable.dart';

enum KycApplicantRole { retailer, rider, other }

/// [unknown] covers any status string the app doesn't know yet.
enum KycReviewStatus { pending, approved, rejected, unknown }

enum KycDecision { approve, reject }

class KycApplicant extends Equatable {
  const KycApplicant({
    required this.id,
    required this.userId,
    required this.name,
    required this.role,
    required this.status,
    required this.rawStatus,
    required this.cnicLast4,
    this.submittedAt,
    this.expiryDate,
    this.phone,
    this.shopLabel,
  });

  static const overdueAfter = Duration(hours: 24);

  /// KYC record id.
  final String id;

  /// Applicant account; the decision endpoint is keyed on this.
  final String userId;
  final String name;
  final KycApplicantRole role;
  final KycReviewStatus status;

  /// Status as sent by the API, for labelling unknown values.
  final String rawStatus;
  final String cnicLast4;
  final DateTime? submittedAt;
  final DateTime? expiryDate;

  /// Not in the API yet; null from remote.
  final String? phone;

  /// "Mehran General Store · SH-021". Not in the API yet; null from remote.
  final String? shopLabel;

  /// "KYC-308" for display, whatever the id format.
  String get reference => RegExp(r'^[A-Za-z]').hasMatch(id) ? id : 'KYC-$id';

  bool get isDecided =>
      status == KycReviewStatus.approved || status == KycReviewStatus.rejected;

  bool isOverdue(DateTime now) =>
      status == KycReviewStatus.pending &&
      submittedAt != null &&
      now.difference(submittedAt!) > overdueAfter;

  KycApplicant copyWith({KycReviewStatus? status, String? rawStatus}) =>
      KycApplicant(
        id: id,
        userId: userId,
        name: name,
        role: role,
        status: status ?? this.status,
        rawStatus: rawStatus ?? this.rawStatus,
        cnicLast4: cnicLast4,
        submittedAt: submittedAt,
        expiryDate: expiryDate,
        phone: phone,
        shopLabel: shopLabel,
      );

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    role,
    status,
    rawStatus,
    cnicLast4,
    submittedAt,
    expiryDate,
    phone,
    shopLabel,
  ];
}

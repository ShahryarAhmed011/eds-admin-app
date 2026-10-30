import '../../../../../core/core.dart';

/// One row of `GET /admin/kyc` (also the body of `POST /admin/kyc`).
class KycSubmissionDto {
  const KycSubmissionDto({
    required this.id,
    required this.userId,
    required this.role,
    required this.nicNumber,
    required this.nameOnCard,
    required this.status,
    this.issueDate,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
    this.phone,
    this.shopLabel,
  });

  factory KycSubmissionDto.fromJson(Json json) => KycSubmissionDto(
    id: json.id(),
    userId: json.id('userId'),
    role: json.strOr('role'),
    nicNumber: json.strOr('nicNumber'),
    nameOnCard: json.strOr('nameOnCard'),
    status: json.strOr('status', 'pending'),
    issueDate: json.date('issueDate'),
    expiryDate: json.date('expiryDate'),
    createdAt: json.date('createdAt'),
    updatedAt: json.date('updatedAt'),
    phone: json.str('phone'),
    shopLabel: json.str('shopLabel'),
  );

  final String id;
  final String userId;
  final String role;

  /// Full NIC as sent by the API. Never leaves the data layer: the mapper
  /// keeps only the last four digits.
  final String nicNumber;
  final String nameOnCard;
  final String status;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Not provided by the API yet (Figma-only, dummy data). Null from remote.
  final String? phone;

  /// Not provided by the API yet (Figma-only, dummy data). Null from remote.
  final String? shopLabel;
}

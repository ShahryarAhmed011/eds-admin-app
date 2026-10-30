import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';

enum KycStatus {
  notSubmitted,
  underReview,
  approved,
  rejected;

  /// API `status`: `pending` (and anything unknown) means waiting for an
  /// admin.
  static KycStatus fromCode(String? code) => switch (code?.toLowerCase()) {
    'approved' || 'verified' || 'accepted' => approved,
    'rejected' || 'declined' => rejected,
    null || '' || 'not_submitted' => notSubmitted,
    _ => underReview,
  };
}

/// The account's identity check (`GET /kyc`), or a blank one before the
/// first submission.
class KycRecord extends Equatable {
  const KycRecord({
    this.status = KycStatus.notSubmitted,
    this.nicNumber = '',
    this.nameOnCard = '',
    this.issueDate,
    this.expiryDate,
    this.reason,
    this.images = const {},
  });

  final KycStatus status;

  /// The document images on file (from `GET /kyc`); a slot is missing
  /// when none was sent.
  final Map<KycImageSlot, Uint8List> images;

  /// 13 digits, no dashes.
  final String nicNumber;
  final String nameOnCard;
  final DateTime? issueDate;
  final DateTime? expiryDate;

  /// Why it was rejected, when the API says.
  final String? reason;

  @override
  List<Object?> get props => [
    status,
    nicNumber,
    nameOnCard,
    issueDate,
    expiryDate,
    reason,
    images.keys.toList(),
  ];
}

/// A KYC document image. [field] is its key in `POST /kyc`; [path] its
/// segment in `GET /kyc/images/{slot}`.
enum KycImageSlot {
  nicFront('nicFront', 'nic_front', 'CNIC front'),
  nicBack('nicBack', 'nic_back', 'CNIC back'),
  selfie('selfie', 'selfie', 'Selfie'),
  vehicleCardFront('vehicleCardFront', 'vehicle_card_front', 'Card front'),
  vehicleCardBack('vehicleCardBack', 'vehicle_card_back', 'Card back');

  const KycImageSlot(this.field, this.path, this.label);

  final String field;
  final String path;
  final String label;

  /// The API's limit per image.
  static const maxBytes = 1024 * 1024;

  /// The images in a `GET /kyc` body: base64 per slot, `""` when that
  /// slot has none.
  static Map<KycImageSlot, Uint8List> decodeAll(Map<String, dynamic> json) => {
    for (final slot in values) slot: ?_decode(json[slot.field]),
  };

  static Uint8List? _decode(Object? value) {
    if (value is! String || value.isEmpty) return null;
    // Also accepts a `data:image/...;base64,` URL.
    final comma = value.startsWith('data:') ? value.indexOf(',') : -1;
    try {
      final bytes = base64Decode(value.substring(comma + 1).trim());
      return bytes.isEmpty ? null : bytes;
    } on FormatException {
      return null;
    }
  }

  /// Images [role] must send: the CNIC both sides and a selfie; riders
  /// also their vehicle registration card.
  static List<KycImageSlot> requiredFor(AppRole role) => [
    nicFront,
    nicBack,
    selfie,
    if (role == AppRole.rider) ...[vehicleCardFront, vehicleCardBack],
  ];
}

/// What the form sends.
class KycSubmission extends Equatable {
  const KycSubmission({
    required this.nicNumber,
    required this.nameOnCard,
    required this.issueDate,
    required this.expiryDate,
    required this.images,
  });

  final String nicNumber;
  final String nameOnCard;
  final DateTime issueDate;
  final DateTime expiryDate;

  /// Each required slot's image (sent as base64).
  final Map<KycImageSlot, Uint8List> images;

  @override
  List<Object?> get props => [
    nicNumber,
    nameOnCard,
    issueDate,
    expiryDate,
    images.keys.toList(),
  ];
}

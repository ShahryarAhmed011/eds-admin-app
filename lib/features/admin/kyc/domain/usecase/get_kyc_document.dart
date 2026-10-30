import 'dart:typed_data';

import '../../../../../core/core.dart';
import '../repository/admin_kyc_repository.dart';

/// One KYC document image of an applicant.
class GetKycDocument
    implements UseCase<Uint8List?, ({String userId, String slot})> {
  const GetKycDocument(this._repository);

  final AdminKycRepository _repository;

  @override
  Future<Uint8List?> call(({String userId, String slot}) params) =>
      _repository.getImage(params.userId, params.slot);
}

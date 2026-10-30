import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';
import '../entities/admin_product_request.dart';
import '../repository/admin_product_requests_repository.dart';

class SubmitProductRequestDecision
    implements UseCase<ProductRequestStatus, ProductRequestDecisionParams> {
  const SubmitProductRequestDecision(this._repository);

  final AdminProductRequestsRepository _repository;

  @override
  Future<ProductRequestStatus> call(ProductRequestDecisionParams params) =>
      _repository.submitDecision(
        request: params.request,
        decision: params.decision,
        reason: params.reason,
      );
}

class ProductRequestDecisionParams extends Equatable {
  const ProductRequestDecisionParams({
    required this.request,
    required this.decision,
    required this.reason,
  });

  final ProductRequestDetail request;
  final ProductRequestDecision decision;
  final String reason;

  @override
  List<Object?> get props => [request, decision, reason];
}

import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';
import '../entities/admin_shop.dart';
import '../repository/admin_shops_repository.dart';

class SubmitShopStatusDecision
    implements UseCase<AdminShop, ShopStatusDecisionParams> {
  const SubmitShopStatusDecision(this._repository);

  final AdminShopsRepository _repository;

  @override
  Future<AdminShop> call(ShopStatusDecisionParams params) =>
      _repository.updateStatus(
        shop: params.shop,
        action: params.action,
        reason: params.reason,
      );
}

class ShopStatusDecisionParams extends Equatable {
  const ShopStatusDecisionParams({
    required this.shop,
    required this.action,
    required this.reason,
  });

  final AdminShop shop;
  final AdminShopStatusAction action;
  final String reason;

  @override
  List<Object?> get props => [shop, action, reason];
}

part of 'admin_shop_detail_bloc.dart';

sealed class AdminShopDetailEvent extends Equatable {
  const AdminShopDetailEvent();

  @override
  List<Object?> get props => [];
}

final class AdminShopDetailRequested extends AdminShopDetailEvent {
  const AdminShopDetailRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class AdminShopStatusDecisionSubmitted extends AdminShopDetailEvent {
  const AdminShopStatusDecisionSubmitted({
    required this.action,
    required this.reason,
  });

  final AdminShopStatusAction action;
  final String reason;

  @override
  List<Object?> get props => [action, reason];
}

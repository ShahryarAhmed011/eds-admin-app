part of 'admin_shop_detail_bloc.dart';

typedef ShopStatusDraft = ({AdminShopStatusAction action, String reason});

sealed class AdminShopDetailState extends Equatable {
  const AdminShopDetailState();

  @override
  List<Object?> get props => [];
}

final class AdminShopDetailLoading extends AdminShopDetailState {
  const AdminShopDetailLoading();
}

final class AdminShopDetailLoaded extends AdminShopDetailState {
  const AdminShopDetailLoaded(
    this.shop, {
    this.isSubmitting = false,
    this.lastAction,
    this.draft,
    this.errorMessage,
    this.errorReference,
  });

  final AdminShop shop;
  final bool isSubmitting;

  /// Set on the state emitted right after a decision is saved.
  final AdminShopStatusAction? lastAction;

  /// Last attempted decision, kept after a failed submit.
  final ShopStatusDraft? draft;

  /// Set on the state emitted right after a failed submit (e.g.
  /// `not_ready_to_go_live`).
  final String? errorMessage;
  final String? errorReference;

  @override
  List<Object?> get props => [
    shop,
    isSubmitting,
    lastAction,
    draft,
    errorMessage,
    errorReference,
  ];
}

final class AdminShopDetailFailure extends AdminShopDetailState {
  const AdminShopDetailFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}

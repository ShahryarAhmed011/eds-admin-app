part of 'admin_product_request_detail_bloc.dart';

sealed class AdminProductRequestDetailState extends Equatable {
  const AdminProductRequestDetailState();

  @override
  List<Object?> get props => [];
}

final class AdminProductRequestDetailLoading
    extends AdminProductRequestDetailState {
  const AdminProductRequestDetailLoading();
}

final class AdminProductRequestDetailLoaded
    extends AdminProductRequestDetailState {
  const AdminProductRequestDetailLoaded(
    this.request, {
    this.isSubmitting = false,
    this.lastDecision,
    this.actionError,
  });

  final ProductRequestDetail request;
  final bool isSubmitting;

  /// Set right after a decision is saved.
  final ProductRequestDecision? lastDecision;

  /// Set right after a decision failed to save.
  final String? actionError;

  @override
  List<Object?> get props => [request, isSubmitting, lastDecision, actionError];
}

final class AdminProductRequestDetailFailure
    extends AdminProductRequestDetailState {
  const AdminProductRequestDetailFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}

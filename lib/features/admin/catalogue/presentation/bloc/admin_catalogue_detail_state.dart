part of 'admin_catalogue_detail_bloc.dart';

sealed class AdminCatalogueDetailState extends Equatable {
  const AdminCatalogueDetailState();

  @override
  List<Object?> get props => [];
}

final class AdminCatalogueDetailLoading extends AdminCatalogueDetailState {
  const AdminCatalogueDetailLoading();
}

final class AdminCatalogueDetailLoaded extends AdminCatalogueDetailState {
  const AdminCatalogueDetailLoaded(
    this.variant, {
    this.isSubmitting = false,
    this.lastAction,
    this.actionError,
  });

  final CatalogueVariantDetail variant;
  final bool isSubmitting;

  /// Set right after an action is saved.
  final CatalogueVariantAction? lastAction;

  /// Set right after an action failed to save.
  final String? actionError;

  @override
  List<Object?> get props => [variant, isSubmitting, lastAction, actionError];
}

final class AdminCatalogueDetailFailure extends AdminCatalogueDetailState {
  const AdminCatalogueDetailFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}

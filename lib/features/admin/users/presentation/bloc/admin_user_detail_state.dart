part of 'admin_user_detail_bloc.dart';

typedef UserAccessDraft = ({AdminUserAccessAction action, String reason});

sealed class AdminUserDetailState extends Equatable {
  const AdminUserDetailState();

  @override
  List<Object?> get props => [];
}

final class AdminUserDetailLoading extends AdminUserDetailState {
  const AdminUserDetailLoading();
}

final class AdminUserDetailLoaded extends AdminUserDetailState {
  const AdminUserDetailLoaded(
    this.user, {
    this.isSubmitting = false,
    this.lastAction,
    this.draft,
    this.errorMessage,
    this.errorReference,
  });

  final AdminUser user;
  final bool isSubmitting;

  /// Set on the state emitted right after a decision is saved.
  final AdminUserAccessAction? lastAction;

  /// Last attempted decision, kept after a failed submit.
  final UserAccessDraft? draft;

  /// Set on the state emitted right after a failed submit.
  final String? errorMessage;
  final String? errorReference;

  @override
  List<Object?> get props => [
    user,
    isSubmitting,
    lastAction,
    draft,
    errorMessage,
    errorReference,
  ];
}

final class AdminUserDetailFailure extends AdminUserDetailState {
  const AdminUserDetailFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}

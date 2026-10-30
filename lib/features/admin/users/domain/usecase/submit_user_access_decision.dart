import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';
import '../entities/admin_user.dart';
import '../repository/admin_users_repository.dart';

class SubmitUserAccessDecision
    implements UseCase<AdminUser, UserAccessDecisionParams> {
  const SubmitUserAccessDecision(this._repository);

  final AdminUsersRepository _repository;

  @override
  Future<AdminUser> call(UserAccessDecisionParams params) =>
      _repository.updateAccess(
        user: params.user,
        action: params.action,
        reason: params.reason,
      );
}

class UserAccessDecisionParams extends Equatable {
  const UserAccessDecisionParams({
    required this.user,
    required this.action,
    required this.reason,
  });

  final AdminUser user;
  final AdminUserAccessAction action;
  final String reason;

  @override
  List<Object?> get props => [user, action, reason];
}

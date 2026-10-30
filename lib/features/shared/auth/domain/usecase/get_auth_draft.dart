import '../../../../../core/core.dart';
import '../entities/auth_draft.dart';
import '../repository/auth_repository.dart';

class GetAuthDraft implements UseCase<AuthDraft, NoParams> {
  const GetAuthDraft(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthDraft> call(NoParams params) => _repository.getDraft();
}

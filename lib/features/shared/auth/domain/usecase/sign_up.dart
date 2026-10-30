import '../../../../../core/core.dart';
import '../entities/auth_draft.dart';
import '../entities/auth_result.dart';
import '../repository/auth_repository.dart';

class SignUpParams {
  const SignUpParams({required this.draft, required this.role});

  final AuthDraft draft;
  final AppRole role;
}

class SignUp implements UseCase<AuthResult, SignUpParams> {
  const SignUp(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthResult> call(SignUpParams params) =>
      _repository.signUp(params.draft, params.role);
}

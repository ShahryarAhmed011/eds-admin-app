import '../../../../../core/core.dart';
import '../repository/auth_repository.dart';

/// Permanently deletes the signed-in account (`DELETE /account`), after the
/// user re-enters their password to confirm. On success the local session is
/// cleared, so the router guard returns to the sign-in screen.
///
/// Throws an [ApiException] on a wrong password (`invalid_credentials`); the
/// account is kept and the caller should surface the message.
class DeleteAccountUseCase implements UseCase<void, String> {
  const DeleteAccountUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(String password) => _repository.deleteAccount(password);
}

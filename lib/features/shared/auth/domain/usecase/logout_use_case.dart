import '../../../../../core/core.dart';
import '../repository/auth_repository.dart';

/// Signs the user out everywhere: `POST /auth/logout` with the stored
/// refresh token (best effort), then clears local tokens.
///
/// Any module's "Sign out" button can call
/// `await sl<LogoutUseCase>()(const NoParams());` and then
/// `context.go(AppRoutes.signIn)`. Never throws.
class LogoutUseCase implements UseCase<void, NoParams> {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.logout();
}

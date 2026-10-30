import '../../../../../core/core.dart';
import '../entities/signed_in_user.dart';
import '../repository/auth_repository.dart';

class SignInParams {
  const SignInParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  final String email;
  final String password;
  final bool rememberMe;
}

class SignIn implements UseCase<SignedInUser, SignInParams> {
  const SignIn(this._repository);

  final AuthRepository _repository;

  @override
  Future<SignedInUser> call(SignInParams params) => _repository.signIn(
    email: params.email.trim(),
    password: params.password,
    rememberMe: params.rememberMe,
  );
}

import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';
import '../entities/auth_result.dart';
import '../repository/auth_repository.dart';

/// Phone login: signs in with a password, or sends a code without one.
class LoginWithPhone implements UseCase<AuthResult, PhoneLoginParams> {
  const LoginWithPhone(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthResult> call(PhoneLoginParams params) =>
      _repository.loginWithPhone(
        params.phoneNumber,
        password: params.password,
        rememberMe: params.rememberMe,
      );
}

class PhoneLoginParams extends Equatable {
  const PhoneLoginParams({
    required this.phoneNumber,
    required this.password,
    required this.rememberMe,
  });

  final String phoneNumber;
  final String password;
  final bool rememberMe;

  @override
  List<Object?> get props => [phoneNumber, password, rememberMe];
}

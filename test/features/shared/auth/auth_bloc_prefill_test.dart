import 'package:eds_admin_app/core/core.dart';
import 'package:eds_admin_app/features/shared/auth/domain/entities/auth_draft.dart';
import 'package:eds_admin_app/features/shared/auth/domain/usecase/get_auth_draft.dart';
import 'package:eds_admin_app/features/shared/auth/domain/usecase/login_with_phone.dart';
import 'package:eds_admin_app/features/shared/auth/domain/usecase/sign_in.dart';
import 'package:eds_admin_app/features/shared/auth/domain/usecase/sign_up.dart';
import 'package:eds_admin_app/features/shared/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Remembered values from a previous login.
class _RememberedDraft implements GetAuthDraft {
  @override
  Future<AuthDraft> call(NoParams params) async =>
      const AuthDraft(phoneNumber: '3001234567', email: 'user@example.com');
}

void main() {
  Future<AuthDraft> draftAfter(AuthStarted event) async {
    final bloc = AuthBloc(
      _RememberedDraft(),
      _UnusedSignIn(),
      _UnusedPhone(),
      _UnusedSignUp(),
    )..add(event);
    final ready = await bloc.stream.firstWhere((s) => s is AuthReady);
    await bloc.close();
    return (ready as AuthReady).draft;
  }

  test('sign in fills in the remembered phone and email', () async {
    final draft = await draftAfter(
      const AuthStarted(loginMethod: LoginMethod.phone),
    );
    expect(draft.phoneNumber, '3001234567');
    expect(draft.email, 'user@example.com');
  });

  test('sign up starts blank', () async {
    final draft = await draftAfter(const AuthStarted(prefill: false));
    expect(draft.phoneNumber, isEmpty);
    expect(draft.email, isEmpty);
  });
}

class _UnusedSignIn implements SignIn {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedPhone implements LoginWithPhone {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedSignUp implements SignUp {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

import 'package:get_it/get_it.dart';

import '../../../core/core.dart';

import 'data/data_sources/auth_data_source.dart';
import 'data/data_sources/auth_remote_data_source.dart';
import 'data/data_sources/remembered_login_storage.dart';
import 'data/repository/auth_repository_impl.dart';
import 'domain/repository/auth_repository.dart';
import 'domain/usecase/get_auth_draft.dart';
import 'domain/usecase/get_pending_verification.dart';
import 'domain/usecase/delete_account_use_case.dart';
import 'domain/usecase/logout_use_case.dart';
import 'domain/usecase/login_with_phone.dart';
import 'domain/usecase/resend_otp.dart';
import 'domain/usecase/sign_in.dart';
import 'domain/usecase/sign_up.dart';
import 'domain/usecase/verify_otp.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/otp_bloc.dart';

void registerSharedAuth(GetIt sl) {
  sl
    // Auth always talks to the API, even when USE_REMOTE_API is off, so the
    // signed-in role comes from a real login response.
    ..registerLazySingleton<AuthDataSource>(() => AuthRemoteDataSource(sl()))
    ..registerLazySingleton<RememberedLoginStorage>(
      SecureRememberedLoginStorage.new,
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        sl(),
        sl(),
        sl(),
        sl<AuthSession>(),
        sl<AuthSession>().cache,
        AppConfig.appRole,
      ),
    )
    ..registerLazySingleton(() => GetAuthDraft(sl()))
    ..registerLazySingleton(() => SignIn(sl()))
    ..registerLazySingleton(() => LoginWithPhone(sl()))
    ..registerLazySingleton(() => SignUp(sl()))
    ..registerLazySingleton(() => GetPendingVerification(sl()))
    ..registerLazySingleton(() => VerifyOtp(sl()))
    ..registerLazySingleton(() => ResendOtp(sl()))
    ..registerLazySingleton(() => LogoutUseCase(sl()))
    ..registerLazySingleton(() => DeleteAccountUseCase(sl()))
    ..registerFactory(() => AuthBloc(sl(), sl(), sl(), sl()))
    ..registerFactory(() => OtpBloc(sl(), sl(), sl()));
}

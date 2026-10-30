import 'package:get_it/get_it.dart';

import '../../../core/core.dart';
import 'data/kyc_repository_impl.dart';
import 'domain/kyc_repository.dart';
import 'presentation/bloc/verify_identity_bloc.dart';

/// Onboarding identity check (retailers and riders): always the API.
void registerSharedKyc(GetIt sl) {
  sl
    ..registerLazySingleton<KycRepository>(
      () => KycRepositoryImpl(sl(), sl<AuthSession>(), sl<AuthSession>().cache),
    )
    ..registerLazySingleton(() => GetKycRecord(sl()))
    ..registerLazySingleton(() => SubmitKyc(sl()))
    ..registerLazySingleton(() => GetKycProfileName(sl()))
    ..registerFactory(() => VerifyIdentityBloc(sl(), sl(), sl()));
}

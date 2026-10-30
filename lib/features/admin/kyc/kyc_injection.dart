import 'package:get_it/get_it.dart';

import 'data/data_sources/admin_kyc_data_source.dart';
import 'data/data_sources/admin_kyc_remote_data_source.dart';
import 'data/repository/admin_kyc_repository_impl.dart';
import 'domain/repository/admin_kyc_repository.dart';
import 'domain/usecase/get_kyc_applicant.dart';
import 'domain/usecase/get_kyc_document.dart';
import 'domain/usecase/get_kyc_review_queue.dart';
import 'domain/usecase/submit_kyc_decision.dart';
import 'presentation/bloc/admin_kyc_detail_bloc.dart';
import 'presentation/bloc/admin_kyc_list_bloc.dart';

void registerAdminKyc(GetIt sl) {
  // Always the API: admins review real accounts.
  sl.registerLazySingleton<AdminKycDataSource>(
    () => AdminKycRemoteDataSource(sl()),
  );
  sl
    ..registerLazySingleton<AdminKycRepository>(
      () => AdminKycRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetKycReviewQueue(sl()))
    ..registerLazySingleton(() => GetKycApplicant(sl()))
    ..registerLazySingleton(() => SubmitKycDecision(sl()))
    ..registerLazySingleton(() => GetKycDocument(sl()))
    ..registerFactory(() => AdminKycListBloc(sl()))
    ..registerFactory(() => AdminKycDetailBloc(sl(), sl()));
}

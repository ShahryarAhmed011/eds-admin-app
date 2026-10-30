import 'package:get_it/get_it.dart';

import '../../../core/core.dart';
import 'data/data_sources/admin_more_data_source.dart';
import 'data/data_sources/admin_more_dummy_data_source.dart';
import 'data/data_sources/admin_more_remote_data_source.dart';
import 'data/repository/admin_more_repository_impl.dart';
import 'domain/repository/admin_more_repository.dart';
import 'domain/usecase/get_admin_profile.dart';
import 'presentation/bloc/admin_more_bloc.dart';

void registerAdminMore(GetIt sl) {
  sl.registerDataSource<AdminMoreDataSource>(
    remote: () => AdminMoreRemoteDataSource(sl()),
    dummy: AdminMoreDummyDataSource.new,
  );
  sl
    ..registerLazySingleton<AdminMoreRepository>(
      () => AdminMoreRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetAdminProfile(sl()))
    ..registerFactory(() => AdminMoreBloc(sl(), sl()));
}

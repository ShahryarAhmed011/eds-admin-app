import 'package:get_it/get_it.dart';

import 'data/data_sources/admin_queues_data_source.dart';
import 'data/data_sources/admin_queues_remote_data_source.dart';
import 'data/repository/admin_queues_repository_impl.dart';
import 'domain/repository/admin_queues_repository.dart';
import 'domain/usecase/get_admin_queues.dart';
import 'presentation/bloc/admin_queues_bloc.dart';

void registerAdminQueues(GetIt sl) {
  // Always the API: admins review real accounts.
  sl.registerLazySingleton<AdminQueuesDataSource>(
    () => AdminQueuesRemoteDataSource(sl()),
  );
  sl
    ..registerLazySingleton<AdminQueuesRepository>(
      () => AdminQueuesRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetAdminQueues(sl()))
    ..registerFactory(() => AdminQueuesBloc(sl()));
}

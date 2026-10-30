import 'package:get_it/get_it.dart';

import '../../../core/core.dart';
import 'data/data_sources/admin_users_data_source.dart';
import 'data/data_sources/admin_users_dummy_data_source.dart';
import 'data/data_sources/admin_users_remote_data_source.dart';
import 'data/repository/admin_users_repository_impl.dart';
import 'domain/repository/admin_users_repository.dart';
import 'domain/usecase/get_admin_user.dart';
import 'domain/usecase/get_admin_users.dart';
import 'domain/usecase/submit_user_access_decision.dart';
import 'presentation/bloc/admin_user_detail_bloc.dart';
import 'presentation/bloc/admin_users_list_bloc.dart';

void registerAdminUsers(GetIt sl) {
  sl.registerDataSource<AdminUsersDataSource>(
    remote: () => AdminUsersRemoteDataSource(sl()),
    dummy: AdminUsersDummyDataSource.new,
  );
  sl
    ..registerLazySingleton<AdminUsersRepository>(
      () => AdminUsersRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetAdminUsers(sl()))
    ..registerLazySingleton(() => GetAdminUser(sl()))
    ..registerLazySingleton(() => SubmitUserAccessDecision(sl()))
    ..registerFactory(() => AdminUsersListBloc(sl()))
    ..registerFactory(() => AdminUserDetailBloc(sl(), sl()));
}

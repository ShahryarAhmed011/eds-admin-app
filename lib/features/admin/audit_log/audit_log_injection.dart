import 'package:get_it/get_it.dart';

import '../../../core/core.dart';
import 'data/data_sources/admin_audit_log_data_source.dart';
import 'data/data_sources/admin_audit_log_dummy_data_source.dart';
import 'data/data_sources/admin_audit_log_remote_data_source.dart';
import 'data/repository/admin_audit_log_repository_impl.dart';
import 'domain/repository/admin_audit_log_repository.dart';
import 'domain/usecase/get_audit_log.dart';
import 'presentation/bloc/admin_audit_log_bloc.dart';

void registerAdminAuditLog(GetIt sl) {
  sl
    ..registerDataSource<AdminAuditLogDataSource>(
      remote: () => AdminAuditLogRemoteDataSource(sl()),
      dummy: AdminAuditLogDummyDataSource.new,
    )
    ..registerLazySingleton<AdminAuditLogRepository>(
      () => AdminAuditLogRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetAuditLog(sl()))
    ..registerFactory(() => AdminAuditLogBloc(sl()));
}

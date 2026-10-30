import 'package:get_it/get_it.dart';

import '../../../core/core.dart';
import 'data/data_sources/admin_areas_data_source.dart';
import 'data/data_sources/admin_areas_dummy_data_source.dart';
import 'data/data_sources/admin_areas_remote_data_source.dart';
import 'data/repository/admin_areas_repository_impl.dart';
import 'domain/repository/admin_areas_repository.dart';
import 'domain/usecase/get_serviceable_areas.dart';
import 'domain/usecase/set_area_serviceability.dart';
import 'presentation/bloc/admin_areas_bloc.dart';

void registerAdminAreas(GetIt sl) {
  sl
    ..registerDataSource<AdminAreasDataSource>(
      remote: () => AdminAreasRemoteDataSource(sl()),
      dummy: AdminAreasDummyDataSource.new,
    )
    ..registerLazySingleton<AdminAreasRepository>(
      () => AdminAreasRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetServiceableAreas(sl()))
    ..registerLazySingleton(() => SetAreaServiceability(sl()))
    ..registerFactory(() => AdminAreasBloc(sl(), sl()));
}

import 'package:get_it/get_it.dart';

import 'data/data_sources/location_data_source.dart';
import 'data/data_sources/location_remote_data_source.dart';
import 'data/repository/location_repository_impl.dart';
import 'domain/repository/location_repository.dart';
import 'domain/usecase/detect_current_location.dart';
import 'domain/usecase/get_location_step.dart';
import 'domain/usecase/request_availability_updates.dart';
import 'domain/usecase/select_location.dart';
import 'presentation/bloc/location_bloc.dart';

void registerSharedLocation(GetIt sl) {
  sl
    // Always the API, like auth: the profile's location ids must be real.
    ..registerLazySingleton<LocationDataSource>(
      () => LocationRemoteDataSource(sl()),
    )
    ..registerLazySingleton<LocationRepository>(
      () => LocationRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton(() => GetLocationStep(sl()))
    ..registerLazySingleton(() => SelectLocation(sl()))
    ..registerLazySingleton(() => DetectCurrentLocation(sl()))
    ..registerLazySingleton(() => RequestAvailabilityUpdates(sl()))
    ..registerFactory(() => LocationBloc(sl(), sl(), sl(), sl()));
}

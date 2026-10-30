import 'package:get_it/get_it.dart';

import '../../../core/core.dart';
import '../location/data/data_sources/location_data_source.dart';
import 'data/data_sources/profile_data_source.dart';
import 'data/data_sources/profile_remote_data_source.dart';
import 'data/repository/profile_repository_impl.dart';
import 'domain/repository/profile_repository.dart';
import 'domain/usecase/get_profile.dart';
import 'domain/usecase/profile_details_usecases.dart';
import 'domain/usecase/update_profile.dart';
import 'presentation/bloc/complete_profile_bloc.dart';
import 'presentation/bloc/profile_bloc.dart';

void registerSharedProfile(GetIt sl) {
  sl
    // Always the API, like auth: it's the signed-in account's profile.
    ..registerLazySingleton<ProfileDataSource>(
      () => ProfileRemoteDataSource(sl()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        sl(),
        sl<AuthSession>(),
        // Without the cache the profile is fetched on every screen.
        AppConfig.persistAccountData ? sl<AuthSession>().cache : null,
        sl<LocationDataSource>(),
      ),
    )
    ..registerLazySingleton(() => GetProfile(sl()))
    ..registerLazySingleton(() => UpdateProfile(sl()))
    ..registerLazySingleton(() => GetProfileDetails(sl()))
    ..registerLazySingleton(() => SaveProfileDetails(sl()))
    ..registerLazySingleton(() => GetGeoOptions(sl()))
    ..registerFactory(() => ProfileBloc(sl(), sl(), sl(), sl(), sl()))
    ..registerLazySingleton(() => GetProfileImage(sl()))
    ..registerLazySingleton(() => UploadProfileImage(sl()))
    ..registerLazySingleton(() => RemoveProfileImage(sl()))
    ..registerFactory(
      () => CompleteProfileBloc(sl(), sl(), sl(), sl(), sl(), sl()),
    );
}

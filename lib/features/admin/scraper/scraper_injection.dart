import 'package:get_it/get_it.dart';

import '../../../core/core.dart';
import 'data/data_sources/admin_scraper_data_source.dart';
import 'data/data_sources/admin_scraper_dummy_data_source.dart';
import 'data/data_sources/admin_scraper_remote_data_source.dart';
import 'data/repository/admin_scraper_repository_impl.dart';
import 'domain/repository/admin_scraper_repository.dart';
import 'domain/usecase/cancel_scraper_import.dart';
import 'domain/usecase/get_scraper_import_results.dart';
import 'domain/usecase/get_scraper_status.dart';
import 'domain/usecase/start_scraper_import.dart';
import 'domain/usecase/start_scraper_run.dart';
import 'presentation/bloc/admin_scraper_bloc.dart';

void registerAdminScraper(GetIt sl) {
  sl
    ..registerDataSource<AdminScraperDataSource>(
      remote: () => AdminScraperRemoteDataSource(sl()),
      dummy: AdminScraperDummyDataSource.new,
    )
    ..registerLazySingleton<AdminScraperRepository>(
      () => AdminScraperRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetScraperStatus(sl()))
    ..registerLazySingleton(() => StartScraperRun(sl()))
    ..registerLazySingleton(() => GetScraperImportResults(sl()))
    ..registerLazySingleton(() => StartScraperImport(sl()))
    ..registerLazySingleton(() => CancelScraperImport(sl()))
    ..registerFactory(() => AdminScraperBloc(sl(), sl(), sl(), sl(), sl()));
}

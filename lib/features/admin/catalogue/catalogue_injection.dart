import 'package:get_it/get_it.dart';

import '../../../core/core.dart';
import 'data/data_sources/admin_catalogue_data_source.dart';
import 'data/data_sources/admin_catalogue_dummy_data_source.dart';
import 'data/data_sources/admin_catalogue_remote_data_source.dart';
import 'data/repository/admin_catalogue_repository_impl.dart';
import 'domain/repository/admin_catalogue_repository.dart';
import 'domain/usecase/get_catalogue_variant.dart';
import 'domain/usecase/get_catalogue_variants.dart';
import 'domain/usecase/submit_catalogue_variant_action.dart';
import 'domain/usecase/update_variant_market_price.dart';
import 'presentation/bloc/admin_catalogue_detail_bloc.dart';
import 'presentation/bloc/admin_catalogue_list_bloc.dart';

void registerAdminCatalogue(GetIt sl) {
  sl
    ..registerDataSource<AdminCatalogueDataSource>(
      remote: () => AdminCatalogueRemoteDataSource(sl()),
      dummy: AdminCatalogueDummyDataSource.new,
    )
    ..registerLazySingleton<AdminCatalogueRepository>(
      () => AdminCatalogueRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetCatalogueVariants(sl()))
    ..registerLazySingleton(() => GetCatalogueVariant(sl()))
    ..registerLazySingleton(() => SubmitCatalogueVariantAction(sl()))
    ..registerLazySingleton(() => UpdateVariantMarketPrice(sl()))
    ..registerFactory(() => AdminCatalogueListBloc(sl()))
    ..registerFactory(() => AdminCatalogueDetailBloc(sl(), sl()));
}

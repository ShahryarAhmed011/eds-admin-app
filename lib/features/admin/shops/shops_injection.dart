import 'package:get_it/get_it.dart';

import '../../../core/core.dart';
import 'data/data_sources/admin_shops_data_source.dart';
import 'data/data_sources/admin_shops_dummy_data_source.dart';
import 'data/data_sources/admin_shops_remote_data_source.dart';
import 'data/repository/admin_shops_repository_impl.dart';
import 'domain/repository/admin_shops_repository.dart';
import 'domain/usecase/get_admin_shop.dart';
import 'domain/usecase/get_admin_shops.dart';
import 'domain/usecase/submit_shop_status_decision.dart';
import 'presentation/bloc/admin_shop_detail_bloc.dart';
import 'presentation/bloc/admin_shops_list_bloc.dart';

void registerAdminShops(GetIt sl) {
  sl.registerDataSource<AdminShopsDataSource>(
    remote: () => AdminShopsRemoteDataSource(sl()),
    dummy: AdminShopsDummyDataSource.new,
  );
  sl
    ..registerLazySingleton<AdminShopsRepository>(
      () => AdminShopsRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetAdminShops(sl()))
    ..registerLazySingleton(() => GetAdminShop(sl()))
    ..registerLazySingleton(() => SubmitShopStatusDecision(sl()))
    ..registerFactory(() => AdminShopsListBloc(sl()))
    ..registerFactory(() => AdminShopDetailBloc(sl(), sl()));
}

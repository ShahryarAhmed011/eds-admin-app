import 'package:get_it/get_it.dart';

import '../../../core/core.dart';
import 'data/data_sources/admin_product_requests_data_source.dart';
import 'data/data_sources/admin_product_requests_dummy_data_source.dart';
import 'data/data_sources/admin_product_requests_remote_data_source.dart';
import 'data/repository/admin_product_requests_repository_impl.dart';
import 'domain/repository/admin_product_requests_repository.dart';
import 'domain/usecase/get_product_request.dart';
import 'domain/usecase/get_product_requests_page.dart';
import 'domain/usecase/submit_product_request_decision.dart';
import 'presentation/bloc/admin_product_request_detail_bloc.dart';
import 'presentation/bloc/admin_product_requests_list_bloc.dart';

void registerAdminProductRequests(GetIt sl) {
  sl
    ..registerDataSource<AdminProductRequestsDataSource>(
      remote: () => AdminProductRequestsRemoteDataSource(sl()),
      dummy: AdminProductRequestsDummyDataSource.new,
    )
    ..registerLazySingleton<AdminProductRequestsRepository>(
      () => AdminProductRequestsRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetProductRequestsPage(sl()))
    ..registerLazySingleton(() => GetProductRequest(sl()))
    ..registerLazySingleton(() => SubmitProductRequestDecision(sl()))
    ..registerFactory(() => AdminProductRequestsListBloc(sl()))
    ..registerFactory(() => AdminProductRequestDetailBloc(sl(), sl()));
}

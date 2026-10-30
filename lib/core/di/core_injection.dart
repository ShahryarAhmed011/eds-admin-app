import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../config/app_config.dart';
import '../location/current_location.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../network/logging_interceptor.dart';
import '../network/token_storage.dart';
import '../session/auth_session.dart';
import '../storage/local_database.dart';
import '../storage/sqlite_stores.dart';
import '../session/session_events.dart';

/// Registers app-wide infrastructure: HTTP client, tokens, session, location.
void registerCore(GetIt sl, {bool inMemoryStorage = false}) {
  final options = BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
    // The envelope carries the error; let ApiClient read every status.
    validateStatus: (status) => status != null && status < 300,
  );

  sl
    ..registerLazySingleton(LocalDatabase.new)
    // Tokens stay in the secure keychain; account data in SQLite tables.
    ..registerLazySingleton(
      () => inMemoryStorage
          ? AuthSession(SecureTokenStorage())
          : AuthSession(
              SecureTokenStorage(),
              SqliteOnboardingStorage(sl()),
              SqliteSessionCache(sl()),
            ),
    )
    // Token writes go through the session so route guards react to them.
    ..registerLazySingleton<TokenStorage>(() => sl<AuthSession>())
    ..registerLazySingleton(SessionEvents.new)
    ..registerLazySingleton<CurrentLocation>(InMemoryCurrentLocation.new)
    ..registerLazySingleton<Dio>(() {
      final dio = Dio(options);
      dio.interceptors.add(
        AuthInterceptor(
          tokenStorage: sl(),
          refreshClient: Dio(options),
          onSessionExpired: sl<SessionEvents>().notifyExpired,
        ),
      );
      if (kDebugMode) {
        dio.interceptors.add(LoggingInterceptor(_logInChunks));
      }
      return dio;
    })
    ..registerLazySingleton(() => ApiClient(sl()));
}

/// Registers a feature data source, choosing the remote implementation when
/// [AppConfig.useRemoteApi] is on and the dummy one otherwise.
///
/// ```dart
/// sl.registerDataSource<ShopDataSource>(
///   remote: () => ShopRemoteDataSource(sl()),
///   dummy: ShopDummyDataSource.new,
/// );
/// ```
extension DataSourceRegistration on GetIt {
  void registerDataSource<T extends Object>({
    required T Function() remote,
    required T Function() dummy,
  }) {
    registerLazySingleton<T>(AppConfig.useRemoteApi ? remote : dummy);
  }
}

/// The device log cuts a line at about 1 KB (the `<…>` in long bodies),
/// so print it in pieces that each fit.
void _logInChunks(Object? message) {
  const size = 800;
  final text = '$message';
  for (var start = 0; start < text.length; start += size) {
    final end = start + size < text.length ? start + size : text.length;
    // Synchronous: debugPrint throttles and drops chunks when several large
    // bodies log at once, which cut responses off half-way.
    debugPrintSynchronously(text.substring(start, end));
  }
  if (text.isEmpty) debugPrintSynchronously('');
}

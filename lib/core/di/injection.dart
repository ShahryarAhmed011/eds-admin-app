import 'package:get_it/get_it.dart';

import '../../features/feature_registry.dart';
import '../../features/splash/splash.dart';
import '../session/auth_session.dart';
import 'core_injection.dart';

final GetIt sl = GetIt.instance;

/// Scope holding every feature registration. Signing out resets its lazy
/// singletons, so no repository keeps the previous account's data in
/// memory.
const featureScope = 'features';

/// [inMemoryStorage] keeps account data in memory instead of SQLite
/// (tests, where the SQLite plugin isn't available).
Future<void> configureDependencies({bool inMemoryStorage = false}) async {
  registerCore(sl, inMemoryStorage: inMemoryStorage);
  _registerSplash();
  sl.pushNewScope(
    scopeName: featureScope,
    init: FeatureRegistry.registerDependencies,
  );
  sl<AuthSession>().onSignedOut(
    () => sl.resetLazySingletons(onlyInScope: featureScope),
  );
}

void _registerSplash() {
  sl
    ..registerLazySingleton<SplashLocalDataSource>(
      () => SplashLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<SplashRepository>(
      () => SplashRepositoryImpl(localDataSource: sl()),
    )
    ..registerLazySingleton(() => InitializeApp(sl()))
    ..registerFactory(() => SplashBloc(initializeApp: sl()));
}

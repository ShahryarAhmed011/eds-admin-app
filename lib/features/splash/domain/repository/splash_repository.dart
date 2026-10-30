import '../entities/app_startup.dart';

abstract interface class SplashRepository {
  Future<AppStartup> initialize();
}

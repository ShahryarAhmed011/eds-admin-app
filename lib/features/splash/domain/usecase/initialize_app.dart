import '../entities/app_startup.dart';
import '../repository/splash_repository.dart';

class InitializeApp {
  const InitializeApp(this._repository);

  final SplashRepository _repository;

  Future<AppStartup> call() => _repository.initialize();
}

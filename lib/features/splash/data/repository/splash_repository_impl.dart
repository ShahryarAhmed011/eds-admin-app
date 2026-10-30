import '../../domain/entities/app_startup.dart';
import '../../domain/repository/splash_repository.dart';
import '../data_sources/splash_local_data_source.dart';
import '../mappers/app_startup_mapper.dart';

class SplashRepositoryImpl implements SplashRepository {
  const SplashRepositoryImpl({required this._localDataSource});

  final SplashLocalDataSource _localDataSource;

  @override
  Future<AppStartup> initialize() async {
    final dto = await _localDataSource.loadStartupData();
    return dto.toEntity();
  }
}

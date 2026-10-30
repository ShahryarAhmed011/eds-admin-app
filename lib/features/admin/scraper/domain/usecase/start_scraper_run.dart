import '../../../../../core/core.dart';
import '../entities/scraper.dart';
import '../repository/admin_scraper_repository.dart';

class StartScraperRun implements UseCase<ScraperRun, NoParams> {
  const StartScraperRun(this._repository);

  final AdminScraperRepository _repository;

  @override
  Future<ScraperRun> call(NoParams params) => _repository.startRun();
}

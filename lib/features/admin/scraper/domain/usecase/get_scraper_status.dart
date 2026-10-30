import '../../../../../core/core.dart';
import '../entities/scraper.dart';
import '../repository/admin_scraper_repository.dart';

class GetScraperStatus implements UseCase<ScraperStatus, NoParams> {
  const GetScraperStatus(this._repository);

  final AdminScraperRepository _repository;

  @override
  Future<ScraperStatus> call(NoParams params) => _repository.getStatus();
}

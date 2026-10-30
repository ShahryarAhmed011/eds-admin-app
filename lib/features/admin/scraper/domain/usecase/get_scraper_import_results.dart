import '../../../../../core/core.dart';
import '../entities/scraper.dart';
import '../repository/admin_scraper_repository.dart';

class GetScraperImportResults
    implements UseCase<ScraperImportResult, NoParams> {
  const GetScraperImportResults(this._repository);

  final AdminScraperRepository _repository;

  @override
  Future<ScraperImportResult> call(NoParams params) =>
      _repository.getImportResults();
}

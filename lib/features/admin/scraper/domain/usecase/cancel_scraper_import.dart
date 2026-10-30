import '../../../../../core/core.dart';
import '../repository/admin_scraper_repository.dart';

class CancelScraperImport implements UseCase<void, NoParams> {
  const CancelScraperImport(this._repository);

  final AdminScraperRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.cancelImport();
}

import '../../../../../core/core.dart';
import '../dto/scraper_dto.dart';
import 'admin_scraper_data_source.dart';

class AdminScraperRemoteDataSource implements AdminScraperDataSource {
  const AdminScraperRemoteDataSource(this._api);

  final ApiClient _api;

  /// `GET /admin/scraper/status`.
  @override
  Future<ScraperStatusDto> fetchStatus() async =>
      ScraperStatusDto.fromJson(await _api.getObject('/admin/scraper/status'));

  /// `POST /admin/scraper/start` (all configured sources).
  @override
  Future<ScraperRunDto> startRun() async =>
      ScraperRunDto.fromJson(_object(await _api.post('/admin/scraper/start')));

  /// `GET /admin/scraper/import-status`.
  @override
  Future<ScraperImportStatusDto> fetchImportStatus() async =>
      ScraperImportStatusDto.fromJson(
        await _api.getObject('/admin/scraper/import-status'),
      );

  /// `GET /admin/scraper/skus?limit=1` and read `total`.
  @override
  Future<int?> countSkus({String? source, bool? imported}) async {
    final data = await _api.getObject(
      '/admin/scraper/skus',
      query: {'source': source, 'imported': imported, 'limit': 1},
    );
    return data.integer('total');
  }

  /// `POST /admin/scraper/import-all`.
  @override
  Future<ScraperImportJobDto> startImportAll() async =>
      ScraperImportJobDto.fromJson(
        _object(await _api.post('/admin/scraper/import-all')),
      );

  /// `POST /admin/scraper/import-all/cancel`.
  @override
  Future<ScraperImportJobDto> cancelImport() async =>
      ScraperImportJobDto.fromJson(
        _object(await _api.post('/admin/scraper/import-all/cancel')),
      );

  Json _object(Object? data) =>
      data is Map ? data.cast<String, dynamic>() : const {};
}

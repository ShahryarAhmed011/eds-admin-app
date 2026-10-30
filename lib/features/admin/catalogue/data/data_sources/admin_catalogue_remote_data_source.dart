import '../../../../../core/core.dart';
import '../dto/catalogue_variant_dto.dart';
import 'admin_catalogue_data_source.dart';
import 'admin_catalogue_dummy_data_source.dart';

/// Admin catalogue API. The backend has no admin list/detail or
/// review-decision endpoints yet, so those stay on [fallback] data; only the
/// market price write is live.
class AdminCatalogueRemoteDataSource implements AdminCatalogueDataSource {
  AdminCatalogueRemoteDataSource(
    this._api, {
    AdminCatalogueDataSource? fallback,
  }) : _fallback = fallback ?? AdminCatalogueDummyDataSource();

  final ApiClient _api;
  final AdminCatalogueDataSource _fallback;

  @override
  Future<CatalogueVariantsPageDto> fetchVariants() => _fallback.fetchVariants();

  @override
  Future<CatalogueVariantDto> fetchVariant(String id) =>
      _fallback.fetchVariant(id);

  /// No endpoint for approve / deactivate / mark-duplicate yet.
  @override
  Future<void> submitVariantAction({
    required String id,
    required String action,
    required String reason,
  }) async => throw const ApiException(
    status: 0,
    code: ApiErrorCode.unknown,
    message: 'Catalogue review decisions are not available yet.',
  );

  /// `PATCH /admin/catalog/variants/{id}`.
  @override
  Future<CatalogueVariantDto> updateMarketPrice({
    required String id,
    required int marketPricePaisa,
  }) async {
    final data = await _api.patch(
      '/admin/catalog/variants/$id',
      body: {'marketPricePaisa': marketPricePaisa},
    );
    return CatalogueVariantDto.fromJson(
      data is Map ? data.cast<String, dynamic>() : {'id': id},
    );
  }
}

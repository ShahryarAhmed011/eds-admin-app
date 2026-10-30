import '../../../../../core/core.dart';
import '../../domain/entities/admin_catalogue_variant.dart';

extension CatalogueVariantStatusLabel on CatalogueVariantStatus {
  String get label => switch (this) {
    CatalogueVariantStatus.active => 'Active',
    CatalogueVariantStatus.inactive => 'Inactive',
    CatalogueVariantStatus.duplicate => 'Duplicate',
  };
}

extension CatalogueVariantSummaryBadge on CatalogueVariantSummary {
  String get badgeLabel => needsReview ? 'Review' : status.label;

  EdsTone get badgeTone {
    if (needsReview) {
      return severity == CatalogueReviewSeverity.high
          ? EdsTone.danger
          : EdsTone.warning;
    }
    return status == CatalogueVariantStatus.active
        ? EdsTone.success
        : EdsTone.neutral;
  }
}

import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';

enum CatalogueVariantStatus { active, inactive, duplicate }

enum CatalogueReviewSeverity { medium, high }

/// Decision taken from the "Catalogue action" sheet.
enum CatalogueVariantAction { approve, deactivate, markDuplicate }

class CatalogueVariantSummary extends Equatable {
  const CatalogueVariantSummary({
    required this.id,
    required this.skuCode,
    required this.name,
    required this.packLabel,
    required this.status,
    this.category,
    this.listNote,
    this.needsReview = false,
    this.severity = CatalogueReviewSeverity.medium,
  });

  final String id;

  /// "SKU-001".
  final String skuCode;
  final String name;

  /// Variant label, e.g. "1 litre".
  final String packLabel;
  final CatalogueVariantStatus status;
  final String? category;

  /// Short context shown in lists ("18 shop listings", "Duplicate barcode").
  final String? listNote;
  final bool needsReview;
  final CatalogueReviewSeverity severity;

  String get displayName => '$name · $packLabel';

  CatalogueVariantSummary copyWith({
    CatalogueVariantStatus? status,
    bool? needsReview,
  }) => CatalogueVariantSummary(
    id: id,
    skuCode: skuCode,
    name: name,
    packLabel: packLabel,
    status: status ?? this.status,
    category: category,
    listNote: listNote,
    needsReview: needsReview ?? this.needsReview,
    severity: severity,
  );

  @override
  List<Object?> get props => [
    id,
    skuCode,
    name,
    packLabel,
    status,
    category,
    listNote,
    needsReview,
    severity,
  ];
}

class CatalogueVariantsPage extends Equatable {
  const CatalogueVariantsPage({
    required this.totalCount,
    required this.reviewCount,
    required this.inactiveCount,
    required this.items,
  });

  final int totalCount;
  final int reviewCount;
  final int inactiveCount;
  final List<CatalogueVariantSummary> items;

  @override
  List<Object?> get props => [totalCount, reviewCount, inactiveCount, items];
}

class CatalogueVariantDetail extends Equatable {
  const CatalogueVariantDetail({
    required this.summary,
    this.description,
    this.marketPrice,
    this.barcode,
    this.unit,
    this.sourceLabel,
    this.linkedListings,
    this.priceMin,
    this.priceMax,
    this.lastEditedLabel,
    this.reviewTitle,
    this.reviewMessage,
  });

  final CatalogueVariantSummary summary;
  final String? description;

  /// Market median / reference price.
  final Money? marketPrice;
  final String? barcode;
  final String? unit;
  final String? sourceLabel;
  final int? linkedListings;
  final Money? priceMin;
  final Money? priceMax;
  final String? lastEditedLabel;
  final String? reviewTitle;
  final String? reviewMessage;

  CatalogueVariantDetail copyWith({
    CatalogueVariantStatus? status,
    bool? needsReview,
    Money? marketPrice,
  }) {
    final review = needsReview ?? summary.needsReview;
    return CatalogueVariantDetail(
      summary: summary.copyWith(status: status, needsReview: needsReview),
      description: description,
      marketPrice: marketPrice ?? this.marketPrice,
      barcode: barcode,
      unit: unit,
      sourceLabel: sourceLabel,
      linkedListings: linkedListings,
      priceMin: priceMin,
      priceMax: priceMax,
      lastEditedLabel: lastEditedLabel,
      reviewTitle: review ? reviewTitle : null,
      reviewMessage: review ? reviewMessage : null,
    );
  }

  @override
  List<Object?> get props => [
    summary,
    description,
    marketPrice,
    barcode,
    unit,
    sourceLabel,
    linkedListings,
    priceMin,
    priceMax,
    lastEditedLabel,
    reviewTitle,
    reviewMessage,
  ];
}

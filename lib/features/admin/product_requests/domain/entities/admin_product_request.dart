import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';

enum ProductRequestStatus { pending, approved, rejected }

/// Decision taken from the "Product request decision" sheet.
enum ProductRequestDecision { approve, reject }

class ProductRequestSummary extends Equatable {
  const ProductRequestSummary({
    required this.id,
    required this.code,
    required this.productName,
    required this.packLabel,
    required this.shopId,
    required this.status,
    this.shopName,
  });

  final String id;

  /// Display reference, e.g. "REQ-104".
  final String code;
  final String productName;

  /// Free-text pack size from the retailer ("800 ml").
  final String packLabel;
  final String shopId;
  final ProductRequestStatus status;
  final String? shopName;

  String get displayName =>
      packLabel.isEmpty ? productName : '$productName · $packLabel';

  /// Shop name, or a reference when the API does not include it.
  String get shopLabel => shopName ?? 'Shop #$shopId';

  ProductRequestSummary copyWith({ProductRequestStatus? status}) =>
      ProductRequestSummary(
        id: id,
        code: code,
        productName: productName,
        packLabel: packLabel,
        shopId: shopId,
        status: status ?? this.status,
        shopName: shopName,
      );

  @override
  List<Object?> get props => [
    id,
    code,
    productName,
    packLabel,
    shopId,
    status,
    shopName,
  ];
}

class ProductRequestsPage extends Equatable {
  const ProductRequestsPage({required this.items, this.totalCount});

  final List<ProductRequestSummary> items;

  /// Server-side total when known; otherwise the loaded item count.
  final int? totalCount;

  int get count => totalCount ?? items.length;

  @override
  List<Object?> get props => [items, totalCount];
}

/// Result of matching a request against existing catalogue variants.
class ProductRequestDuplicateCheck extends Equatable {
  const ProductRequestDuplicateCheck({
    required this.isDuplicate,
    required this.title,
    this.message,
  });

  final bool isDuplicate;
  final String title;
  final String? message;

  @override
  List<Object?> get props => [isDuplicate, title, message];
}

class ProductRequestDetail extends Equatable {
  const ProductRequestDetail({
    required this.summary,
    this.brand,
    this.description,
    this.submittedAt,
    this.category,
    this.categoryId,
    this.barcode,
    this.packDetail,
    this.shopOwner,
    this.shopPhone,
    this.duplicateCheck,
    this.suggestedPrice,
    this.retailerNote,
    this.rejectionReason,
  });

  final ProductRequestSummary summary;
  final String? brand;
  final String? description;
  final DateTime? submittedAt;

  /// Category name, or null when only [categoryId] is known.
  final String? category;
  final String? categoryId;
  final String? barcode;
  final String? packDetail;
  final String? shopOwner;
  final String? shopPhone;
  final ProductRequestDuplicateCheck? duplicateCheck;
  final Money? suggestedPrice;
  final String? retailerNote;
  final String? rejectionReason;

  ProductRequestDetail copyWith({ProductRequestStatus? status}) =>
      ProductRequestDetail(
        summary: summary.copyWith(status: status),
        brand: brand,
        description: description,
        submittedAt: submittedAt,
        category: category,
        categoryId: categoryId,
        barcode: barcode,
        packDetail: packDetail,
        shopOwner: shopOwner,
        shopPhone: shopPhone,
        duplicateCheck: duplicateCheck,
        suggestedPrice: suggestedPrice,
        retailerNote: retailerNote,
        rejectionReason: rejectionReason,
      );

  @override
  List<Object?> get props => [
    summary,
    brand,
    description,
    submittedAt,
    category,
    categoryId,
    barcode,
    packDetail,
    shopOwner,
    shopPhone,
    duplicateCheck,
    suggestedPrice,
    retailerNote,
    rejectionReason,
  ];
}

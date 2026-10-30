import '../../../../../core/core.dart';
import '../../domain/entities/admin_product_request.dart';

extension ProductRequestStatusLabel on ProductRequestStatus {
  String get label => switch (this) {
    ProductRequestStatus.pending => 'Pending',
    ProductRequestStatus.approved => 'Approved',
    ProductRequestStatus.rejected => 'Rejected',
  };

  EdsTone get tone => switch (this) {
    ProductRequestStatus.pending => EdsTone.warning,
    ProductRequestStatus.approved => EdsTone.success,
    ProductRequestStatus.rejected => EdsTone.danger,
  };
}

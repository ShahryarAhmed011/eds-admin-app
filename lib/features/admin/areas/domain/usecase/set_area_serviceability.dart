import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';
import '../entities/service_area.dart';
import '../repository/admin_areas_repository.dart';

class SetAreaServiceability
    implements UseCase<ServiceArea, AreaServiceabilityParams> {
  const SetAreaServiceability(this._repository);

  final AdminAreasRepository _repository;

  @override
  Future<ServiceArea> call(AreaServiceabilityParams params) =>
      _repository.setServiceability(
        area: params.area,
        serviceable: params.serviceable,
        reason: params.reason,
      );
}

class AreaServiceabilityParams extends Equatable {
  const AreaServiceabilityParams({
    required this.area,
    required this.serviceable,
    required this.reason,
  });

  final ServiceArea area;
  final bool serviceable;
  final String reason;

  @override
  List<Object?> get props => [area, serviceable, reason];
}

import '../../../../core/session/app_role.dart';
import '../../domain/entities/app_startup.dart';
import '../dto/app_startup_dto.dart';

extension AppStartupDtoMapper on AppStartupDto {
  AppStartup toEntity() =>
      AppStartup(role: role == null ? null : AppRole.fromApi(role));
}

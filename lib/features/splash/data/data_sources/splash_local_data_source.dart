import '../../../../core/session/auth_session.dart';
import '../dto/app_startup_dto.dart';

abstract interface class SplashLocalDataSource {
  Future<AppStartupDto> loadStartupData();
}

class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  const SplashLocalDataSourceImpl(this._session);

  final AuthSession _session;

  /// How long the splash stays up, even when restoring is instant. The
  /// logo animation finishes at 2.8 s and then holds.
  static const _minimumDisplay = Duration(seconds: 5);

  @override
  Future<AppStartupDto> loadStartupData() async {
    final results = await Future.wait([
      _session.restore().then((_) => _session.role?.apiValue),
      Future<void>.delayed(_minimumDisplay),
    ]);
    return AppStartupDto(role: results.first as String?);
  }
}

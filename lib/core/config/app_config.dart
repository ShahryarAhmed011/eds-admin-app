import '../session/app_role.dart';

/// Build-time configuration. Override with `--dart-define`, e.g.
/// `flutter run --dart-define=USE_REMOTE_API=false` for offline demo data.
abstract final class AppConfig {
  /// The one role this build serves. Each app sets its own value at fork
  /// time (docs/multi-app-extraction-plan.md): sign up registers this role
  /// without asking, and a login as any other role is refused.
  static const appRole = AppRole.admin;

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.edoorstep.com/api/v1',
  );

  /// The real API by default. When false every feature uses its dummy
  /// data source (offline Figma data) — for tests and demos only. Set
  /// before `configureDependencies`.
  static bool useRemoteApi = const bool.fromEnvironment(
    'USE_REMOTE_API',
    defaultValue: true,
  );

  /// Keep the signed-in account's profile and store on the device (SQLite)
  /// and serve screens from that copy, writing updates through. Off for
  /// now: every screen fetches them from the API while the live backend is
  /// being checked (the login `user` block and the profile picture are
  /// still cached). Flip with `--dart-define=PERSIST_ACCOUNT_DATA=true`.
  static const persistAccountData = bool.fromEnvironment(
    'PERSIST_ACCOUNT_DATA',
    defaultValue: false,
  );

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);
}

import 'dart:io';

import 'package:eds_admin_app/app.dart';
import 'package:eds_admin_app/core/config/app_config.dart';
import 'package:eds_admin_app/core/di/injection.dart';
import 'package:eds_admin_app/core/network/token_storage.dart';
import 'package:eds_admin_app/core/router/app_router.dart';
import 'package:eds_admin_app/core/router/app_routes.dart';
import 'package:eds_admin_app/core/router/role_home.dart';
import 'package:eds_admin_app/core/session/app_role.dart';
import 'package:eds_admin_app/core/session/auth_session.dart';
import 'package:eds_admin_app/features/admin/kyc/data/data_sources/admin_kyc_data_source.dart';
import 'package:eds_admin_app/features/admin/kyc/data/data_sources/admin_kyc_dummy_data_source.dart';
import 'package:eds_admin_app/features/admin/queues/data/data_sources/admin_queues_data_source.dart';
import 'package:eds_admin_app/features/admin/queues/data/data_sources/admin_queues_dummy_data_source.dart';
import 'package:eds_admin_app/features/feature_registry.dart';
import 'package:eds_admin_app/features/shared/location/data/data_sources/location_data_source.dart';
import 'package:eds_admin_app/features/shared/location/data/data_sources/location_dummy_data_source.dart';
import 'package:eds_admin_app/features/shared/profile/data/data_sources/profile_data_source.dart';
import 'package:eds_admin_app/features/shared/profile/data/data_sources/profile_dummy_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Drives the real app on dummy data at the Figma frame size (360x800):
/// cold start, route guards, and every route this build's role
/// ([AppConfig.appRole]) can open. Fails on any exception, layout overflow
/// or missing dependency registration.
void main() {
  setUpAll(() async {
    FlutterSecureStorage.setMockInitialValues({});
    // flutter_test renders the wide Ahem font by default; load the bundled
    // Inter so overflow checks match the device.
    final loader = FontLoader('Inter');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      final bytes = File(
        'assets/fonts/inter/Inter-$weight.ttf',
      ).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
    // In-memory account storage: SQLite needs the device plugin.
    // Dummy data throughout: no network in tests.
    AppConfig.useRemoteApi = false;
    await configureDependencies(inMemoryStorage: true);
    // The app always reads profile and location from the API; this test
    // drives the dummy data instead.
    sl
      ..allowReassignment = true
      ..registerLazySingleton<ProfileDataSource>(ProfileDummyDataSource.new)
      ..registerLazySingleton<LocationDataSource>(LocationDummyDataSource.new)
      ..registerLazySingleton<AdminKycDataSource>(AdminKycDummyDataSource.new)
      ..registerLazySingleton<AdminQueuesDataSource>(
        AdminQueuesDummyDataSource.new,
      )
      ..allowReassignment = false;
  });

  AuthSession session() => sl<AuthSession>();

  Future<void> settle(WidgetTester tester) async {
    // Dummy data sources resolve after ~350 ms; the splash holds 5 s.
    for (var i = 0; i < 18; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  Future<void> boot(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EdsApp());
    await settle(tester);
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  String location() => appRouter.routerDelegate.state.matchedLocation;

  testWidgets('cold start without a session lands on sign in', (tester) async {
    await session().clear();
    appRouter.go(AppRoutes.splash);
    await boot(tester);

    expect(location(), AppRoutes.signIn);
    expect(tester.takeException(), isNull);
    await teardown(tester);
  });

  testWidgets('protected routes redirect to sign in when signed out', (
    tester,
  ) async {
    await session().clear();
    await boot(tester);
    appRouter.go(AppConfig.appRole.homeRoute);
    await settle(tester);

    expect(location(), AppRoutes.signIn);
    await teardown(tester);
  });

  final paths = _routePaths(FeatureRegistry.routes);
  const shared = ['/profile', '/location/'];

  // One role per app: the others' routes are not registered.
  for (final role in [AppConfig.appRole]) {
    testWidgets('${role.label}: cold start with a session opens role home', (
      tester,
    ) async {
      await session().write(_tokens(role));
      appRouter.go(AppRoutes.splash);
      await boot(tester);

      expect(location(), role.homeRoute);
      expect(tester.takeException(), isNull);
      await teardown(tester);
    });

    final own = paths.where(
      (p) =>
          p.startsWith(role.routePrefix) || shared.any((s) => p.startsWith(s)),
    );
    for (final path in own) {
      testWidgets('${role.label}: $path renders', (tester) async {
        await session().write(_tokens(role));
        await boot(tester);
        appRouter.go(path);
        await settle(tester);

        expect(location(), path, reason: 'unexpected redirect');
        expect(tester.takeException(), isNull);
        await teardown(tester);
      });
    }
  }

  testWidgets("a role cannot open another role's screens", (tester) async {
    final other = AppRole.values.firstWhere((r) => r != AppConfig.appRole);
    await session().write(_tokens(AppConfig.appRole));
    await boot(tester);
    appRouter.go(other.homeRoute);
    await settle(tester);

    expect(location(), AppConfig.appRole.homeRoute);
    await teardown(tester);
  });
}

AuthTokens _tokens(AppRole role) =>
    AuthTokens(accessToken: 'test', refreshToken: 'test', role: role.apiValue);

/// Every concrete GoRoute path (parameterised paths are skipped).
List<String> _routePaths(List<RouteBase> routes) => [
  for (final route in routes) ...[
    if (route is GoRoute && !route.path.contains(':')) route.path,
    ..._routePaths(route.routes),
  ],
];

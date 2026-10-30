import 'package:eds_admin_app/core/session/app_role.dart';
import 'package:eds_admin_app/features/splash/splash.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements SplashRepository {
  _FakeRepository(this.startup);

  final AppStartup startup;

  @override
  Future<AppStartup> initialize() async => startup;
}

void main() {
  test('restored session emits loaded with the role', () async {
    const startup = AppStartup(role: AppRole.retailer);
    final bloc = SplashBloc(
      initializeApp: InitializeApp(_FakeRepository(startup)),
    );

    final states = bloc.stream.take(2).toList();
    bloc.add(const SplashStarted());

    expect(await states, const [SplashLoading(), SplashLoaded(startup)]);
    await bloc.close();
  });

  test('no session means signed out', () {
    expect(const AppStartup().isSignedIn, isFalse);
  });
}

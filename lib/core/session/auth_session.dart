import 'package:flutter/foundation.dart';

import '../network/token_storage.dart';
import 'app_role.dart';
import 'onboarding.dart';
import 'session_cache.dart';

/// The signed-in state of the app, observable by the router.
///
/// It is also the app's [TokenStorage]: every token write or clear made by
/// any feature (sign in, OTP verify, refresh, logout) flows through here, so
/// route guards update automatically.
///
/// A session whose phone / email still needs its code is kept in memory
/// only: it is saved once verified, so restarting the app mid-verification
/// opens log in instead of the code screen.
class AuthSession extends ChangeNotifier
    implements TokenStorage, OnboardingTracker {
  AuthSession(
    this._storage, [
    OnboardingStorage? onboarding,
    SessionCache? cache,
  ]) : _onboardingStorage = onboarding ?? MemoryOnboardingStorage(),
       cache = cache ?? MemorySessionCache();

  final TokenStorage _storage;
  final OnboardingStorage _onboardingStorage;

  /// The signed-in user's data on the device; cleared on sign out.
  final SessionCache cache;
  AppRole? _role;
  OnboardingStatus? _onboarding;
  bool _restored = false;

  /// Tokens not saved yet: the account is still verifying its contact.
  AuthTokens? _unsaved;

  final _signedOutHandlers = <Future<void> Function()>[];

  /// Runs [handler] whenever the session is cleared (sign out, expired
  /// session), e.g. to drop data held in memory.
  void onSignedOut(Future<void> Function() handler) =>
      _signedOutHandlers.add(handler);

  /// Role of the signed-in account, or null when signed out.
  @override
  AppRole? get role => _role;
  bool get isSignedIn => _role != null;

  /// What the account has finished, as last reported by the API (plus
  /// steps finished since). Null when not reported: no onboarding gate.
  OnboardingStatus? get onboarding => _onboarding;

  /// The step the signed-in account must finish next, or null.
  @override
  OnboardingStep? get onboardingStep {
    final role = _role;
    if (role == null) return null;
    return _onboarding?.nextStep(role);
  }

  /// Saves the status from a login / sign up response; null forgets it.
  @override
  Future<void> setOnboarding(OnboardingStatus? status) async {
    _onboarding = status;
    await (status == null
        ? _onboardingStorage.clear()
        : _onboardingStorage.write(status));
    // Verified now: the session can be saved.
    if (_unsaved case final tokens? when !_verifying(tokens)) {
      _unsaved = null;
      await _storage.write(tokens);
    }
    notifyListeners();
  }

  /// Marks [step] finished, e.g. after the profile is saved, so the
  /// router moves on.
  @override
  Future<void> completeOnboarding(OnboardingStep step) async {
    final current = _onboarding;
    if (current == null) return;
    await setOnboarding(current.complete(step));
  }

  /// Whether the stored session has been read since launch.
  bool get isRestored => _restored;

  /// Loads the persisted session. Call once at startup (the splash does).
  Future<void> restore() async {
    final (tokens, onboarding) = await (
      _storage.read(),
      _readOnboarding(),
    ).wait;
    _onboarding = tokens == null ? null : onboarding;
    _restored = true;
    // Saved mid-verification by an older version: start from log in.
    if (tokens != null && _verifying(tokens)) {
      await clear();
      return;
    }
    _setRole(tokens == null ? null : AppRole.fromApi(tokens.role));
  }

  /// The saved status, or null when the local database can't answer
  /// (e.g. a build without the SQLite plugin): start-up must never hang
  /// on it. Logged so the cause is visible.
  Future<OnboardingStatus?> _readOnboarding() async {
    try {
      return await _onboardingStorage.read().timeout(
        const Duration(seconds: 5),
      );
    } catch (error, stack) {
      debugPrint('AuthSession: onboarding status unavailable: $error');
      debugPrintStack(stackTrace: stack, maxFrames: 5);
      return null;
    }
  }

  @override
  Future<AuthTokens?> read() async => _unsaved ?? await _storage.read();

  @override
  Future<void> write(AuthTokens tokens) async {
    if (_verifying(tokens)) {
      // Not properly logged in until the code is verified: memory only.
      _unsaved = tokens;
      await _storage.clear();
    } else {
      _unsaved = null;
      await _storage.write(tokens);
    }
    _restored = true;
    _setRole(AppRole.fromApi(tokens.role));
  }

  /// Signs out on this device: tokens, onboarding status, every cached
  /// table and in-memory feature data.
  @override
  Future<void> clear() async {
    _unsaved = null;
    await _storage.clear();
    try {
      await (_onboardingStorage.clear(), cache.clear()).wait;
    } catch (error) {
      // Tokens and memory are cleared regardless; log what couldn't be.
      debugPrint('AuthSession: local tables not cleared: $error');
    }
    _onboarding = null;
    for (final handler in _signedOutHandlers) {
      await handler();
    }
    _setRole(null);
  }

  /// Whether the account behind [tokens] still has to verify its phone or
  /// email.
  bool _verifying(AuthTokens tokens) {
    final step = _onboarding?.nextStep(AppRole.fromApi(tokens.role));
    return step == OnboardingStep.verifyPhone ||
        step == OnboardingStep.verifyEmail;
  }

  void _setRole(AppRole? role) {
    if (role == _role) return;
    _role = role;
    notifyListeners();
  }
}

import 'dart:async';

import 'package:dio/dio.dart';

import 'token_storage.dart';

/// Attaches the bearer token and transparently rotates it on a 401.
///
/// Concurrent 401s share a single refresh call. If the refresh fails the
/// tokens are cleared and [onSessionExpired] fires so the app can route to
/// sign in.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required this._refreshClient,
    required this._onSessionExpired,
  }) : _tokens = tokenStorage;

  final TokenStorage _tokens;

  /// A bare Dio (no interceptors) so refreshing can't recurse.
  final Dio _refreshClient;
  final void Function() _onSessionExpired;

  static const _retriedKey = 'eds.retried';

  /// Paths that never carry a bearer token or trigger a refresh.
  static const _publicAuthPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/signup',
    '/auth/otp/verify',
    '/auth/otp/resend',
    '/auth/refresh',
  ];

  bool _isPublicAuth(RequestOptions o) =>
      _publicAuthPaths.any((p) => o.path.endsWith(p));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicAuth(options)) {
      final tokens = await _tokens.read();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final shouldRefresh =
        err.response?.statusCode == 401 &&
        !_isPublicAuth(request) &&
        request.extra[_retriedKey] != true;
    if (!shouldRefresh) return handler.next(err);

    final current = await _tokens.read();
    if (current == null) return handler.next(err);

    // Another queued request may already have refreshed the token.
    final sentToken = request.headers['Authorization'];
    var tokens = current;
    if (sentToken == 'Bearer ${current.accessToken}') {
      final refreshed = await _refresh(current.refreshToken);
      if (refreshed == null) {
        await _tokens.clear();
        _onSessionExpired();
        return handler.next(err);
      }
      tokens = refreshed;
    }

    try {
      request
        ..headers['Authorization'] = 'Bearer ${tokens.accessToken}'
        ..extra[_retriedKey] = true;
      handler.resolve(await _refreshClient.fetch<dynamic>(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<AuthTokens?> _refresh(String refreshToken) async {
    try {
      final response = await _refreshClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) return null;
      final tokens = AuthTokens.fromJson(data);
      await _tokens.write(tokens);
      return tokens;
    } on DioException {
      return null;
    }
  }
}

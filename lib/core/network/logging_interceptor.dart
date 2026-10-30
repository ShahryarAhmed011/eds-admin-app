import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Dev-only request/response logger. Unlike Dio's [LogInterceptor], it never
/// dumps raw bytes: a binary body (e.g. `GET /profile/image`) is logged as a
/// short `<image/png · 198250 bytes>` placeholder instead of the whole array.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor(this._print);

  final void Function(Object?) _print;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _print('*** Request → ${options.method} ${options.uri}');
    final body = options.data;
    if (body != null) _print('data: ${_describe(body, options.contentType)}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final r = response.requestOptions;
    _print('*** Response ← ${response.statusCode} ${r.method} ${r.uri}');
    _print('data: ${_describe(response.data, _contentType(response))}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final r = err.requestOptions;
    _print(
      '*** Error ✗ ${err.response?.statusCode ?? '-'} ${r.method} ${r.uri}',
    );
    _print('message: ${err.message}');
    handler.next(err);
  }

  /// Summarises binary bodies; otherwise prints the (truncated) value.
  static String _describe(Object? data, String? contentType) {
    if (data is Uint8List || data is List<int>) {
      final length = (data as List).length;
      final type = contentType == null ? '' : '$contentType · ';
      return '<$type$length bytes>';
    }
    final text = '$data';
    const max = 2000;
    return text.length <= max ? text : '${text.substring(0, max)}… (truncated)';
  }

  static String? _contentType(Response<dynamic> response) =>
      response.headers.value('content-type');
}

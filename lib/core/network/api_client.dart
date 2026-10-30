import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'json.dart';
import 'paginated.dart';

/// Thin wrapper over Dio that unwraps the response envelope.
///
/// Every method returns the envelope's `data` (already checked for
/// `success`) and throws [ApiException] on any failure, so remote data
/// sources only deal with payloads.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: _clean(query)));

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) => _send(
    () => _dio.post<dynamic>(path, data: body, queryParameters: _clean(query)),
  );

  Future<dynamic> put(String path, {Object? body}) =>
      _send(() => _dio.put<dynamic>(path, data: body));

  Future<dynamic> patch(String path, {Object? body}) =>
      _send(() => _dio.patch<dynamic>(path, data: body));

  Future<dynamic> delete(String path, {Object? body}) =>
      _send(() => _dio.delete<dynamic>(path, data: body));

  /// GET of a raw file (e.g. an image), not the JSON envelope. Null on
  /// 404.
  Future<Uint8List?> getBytes(String path) async {
    try {
      final response = await _dio.get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      return bytes == null ? null : Uint8List.fromList(bytes);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _fromDio(e);
    }
  }

  /// GET returning a single object payload.
  Future<Json> getObject(String path, {Map<String, dynamic>? query}) async =>
      _asJson(await get(path, query: query));

  /// GET a collection at `data.items`, following no pages.
  Future<List<Json>> getItems(
    String path, {
    Map<String, dynamic>? query,
  }) async => _asJson(await get(path, query: query)).objList('items');

  /// GET one page of a cursor-paginated collection.
  Future<Paginated<Json>> getPage(
    String path, {
    Map<String, dynamic>? query,
    String? cursor,
    int limit = 20,
  }) async {
    final envelope = await _sendRaw(
      () => _dio.get<dynamic>(
        path,
        queryParameters: _clean({...?query, 'cursor': cursor, 'limit': limit}),
      ),
    );
    final pagination = envelope.obj('pagination');
    return Paginated(
      items: _asJson(envelope['data']).objList('items'),
      nextCursor: pagination?.str('nextCursor'),
      hasNext: pagination?.boolean('hasNext') ?? false,
    );
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async =>
      (await _sendRaw(call))['data'];

  Future<Json> _sendRaw(Future<Response<dynamic>> Function() call) async {
    try {
      final body = (await call()).data;
      if (body is! Map) throw _malformed();
      final envelope = body.cast<String, dynamic>();
      if (envelope['success'] != true) throw _fromEnvelope(envelope, 0);
      return envelope;
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Json _asJson(dynamic data) {
    if (data is Map) return data.cast<String, dynamic>();
    throw _malformed();
  }

  Map<String, dynamic>? _clean(Map<String, dynamic>? query) =>
      query == null ? null : (Map.of(query)..removeWhere((_, v) => v == null));

  ApiException _fromDio(DioException e) {
    final body = e.response?.data;
    if (body is Map) {
      return _fromEnvelope(
        body.cast<String, dynamic>(),
        e.response?.statusCode,
      );
    }
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => const ApiException(
        status: 0,
        code: ApiErrorCode.timeout,
        message: 'The server took too long to respond. Please try again.',
      ),
      DioExceptionType.connectionError => const ApiException(
        status: 0,
        code: ApiErrorCode.networkUnavailable,
        message: 'No internet connection.',
      ),
      _ => ApiException(
        status: e.response?.statusCode ?? 0,
        code: ApiErrorCode.unknown,
        message: 'Something went wrong. Please try again.',
      ),
    };
  }

  ApiException _fromEnvelope(Json envelope, int? httpStatus) {
    final error = envelope.obj('error');
    return ApiException(
      status: envelope.integer('status') ?? httpStatus ?? 0,
      code: error?.str('code') ?? ApiErrorCode.unknown,
      message: envelope.strOr('message', 'Something went wrong.'),
      requestId: envelope.obj('meta')?.str('requestId'),
      fields: error?['fields'],
    );
  }

  ApiException _malformed() => const ApiException(
    status: 0,
    code: ApiErrorCode.malformedResponse,
    message: 'Unexpected response from the server.',
  );
}

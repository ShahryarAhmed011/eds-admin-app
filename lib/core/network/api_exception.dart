/// A failed API call. Branch on [status] and [code]; never on [message].
class ApiException implements Exception {
  const ApiException({
    required this.status,
    required this.code,
    required this.message,
    this.requestId,
    this.fields,
  });

  /// HTTP status, or 0 when the request never reached the server.
  final int status;

  /// `error.code` from the envelope, or one of the client-side codes in
  /// [ApiErrorCode].
  final String code;

  /// Human-readable text. Safe to show, but don't parse it.
  final String message;

  /// `meta.request_id`; show it on error screens for traceable bug reports.
  final String? requestId;

  /// Extra error detail (e.g. the unmet go-live checklist).
  final Object? fields;

  bool get isNetwork => code == ApiErrorCode.networkUnavailable;
  bool get isUnauthorized => status == 401;

  @override
  String toString() => message;
}

/// Error codes the app branches on. Server codes come from the API docs;
/// client-only codes are prefixed `client_`.
abstract final class ApiErrorCode {
  // Client-side
  static const networkUnavailable = 'client_network_unavailable';
  static const timeout = 'client_timeout';
  static const malformedResponse = 'client_malformed_response';
  static const unknown = 'client_unknown';

  /// The account belongs to another role's app (each role ships as its own
  /// app); raised before any session is written.
  static const wrongApp = 'client_wrong_app';

  // Auth
  static const invalidCredentials = 'invalid_credentials';
  static const rateLimited = 'rate_limited';
  static const otpInvalid = 'otp_invalid';
  static const otpExpired = 'otp_expired';
  static const otpLocked = 'otp_locked';
  static const tokenInvalid = 'token_invalid';
  static const tokenReused = 'token_reused';
  static const missingBearerToken = 'missing_bearer_token';
  static const emailInUse = 'email_in_use';
  static const phoneInUse = 'phone_in_use';
  static const usernameInUse = 'username_in_use';
  static const invalidRequest = 'invalid_request';

  // Domain
  static const notFound = 'not_found';
  static const barcodeUnknown = 'barcode_unknown';
  static const requiredNoMarketPrice = 'required_no_market_price';
  static const retailerOnly = 'retailer_only';
  static const notReadyToGoLive = 'not_ready_to_go_live';
  static const scrapeRunActive = 'scrape_run_active';
  static const catalogImportActive = 'catalog_import_active';
}

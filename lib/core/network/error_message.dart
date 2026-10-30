import 'api_exception.dart';

/// User-facing text for any error thrown below the presentation layer.
String errorMessage(Object error) => switch (error) {
  ApiException(:final message) => message,
  _ => 'Something went wrong. Please try again.',
};

/// `meta.request_id` when available, for the "Reference:" line.
String? errorReference(Object error) =>
    error is ApiException ? error.requestId : null;

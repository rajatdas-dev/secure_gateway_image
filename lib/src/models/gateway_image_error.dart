import 'gateway_image_stage.dart';

/// Detailed error information when an image source fails.
class GatewayImageError {
  const GatewayImageError({
    required this.message,
    this.error,
    this.stackTrace,
    this.stage,
    this.source,
    this.retryAttempts = 0,
    this.totalRetryDuration = Duration.zero,
  });

  /// Human-readable explanation of the error.
  final String message;

  /// Underlying error or exception object, if available.
  final Object? error;

  /// Stack trace associated with the error.
  final StackTrace? stackTrace;

  /// The fallback stage where the error occurred.
  final GatewayImageStage? stage;

  /// The source URI or path that failed (e.g. network URL or asset path).
  final String? source;

  /// The number of retry attempts made before giving up.
  final int retryAttempts;

  /// Total duration spent attempting retries.
  final Duration totalRetryDuration;

  @override
  String toString() => 'GatewayImageError($message, stage: $stage, attempts: $retryAttempts)';
}

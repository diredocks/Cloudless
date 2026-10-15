/// Categories of failure the UI can translate on its own. The [detail] carries
/// any service-provided text (already localized by the requested `lang`).
enum WeatherErrorKind {
  unreachable,
  badStatus,
  invalidData,
  serviceError,
  noData,
}

/// Raised when the Caiyun weather service cannot be reached or answers with an
/// error.
class WeatherApiException implements Exception {
  const WeatherApiException(this.kind, {this.detail, this.statusCode});

  final WeatherErrorKind kind;

  /// Service-provided error text, when available.
  final String? detail;

  /// HTTP status code, set for [WeatherErrorKind.badStatus].
  final int? statusCode;

  @override
  String toString() => detail ?? kind.name;
}

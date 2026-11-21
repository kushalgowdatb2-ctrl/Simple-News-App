abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Thrown when device has no internet connection or DNS lookup fails.
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Please verify your connection and try again.',
  ]);
}

/// Thrown when HTTP request times out.
class RequestTimeoutException extends AppException {
  const RequestTimeoutException([
    super.message = 'Connection timed out. The server took too long to respond.',
  ]);
}

/// Thrown when server responds with 404.
class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'Requested article or resource was not found.',
    super.statusCode = 404,
  ]);
}

/// Thrown when server responds with 5xx or unhandled 4xx error.
class ServerException extends AppException {
  const ServerException([
    super.message = 'A server error occurred. Please try again later.',
    super.statusCode,
  ]);
}

/// Thrown when JSON parsing or schema mismatch occurs.
class ParseException extends AppException {
  const ParseException([
    super.message = 'Failed to parse response data correctly.',
  ]);
}

/// Thrown for any other unexpected exception.
class UnknownException extends AppException {
  const UnknownException([
    super.message = 'An unexpected error occurred. Please try again.',
    super.statusCode,
  ]);
}


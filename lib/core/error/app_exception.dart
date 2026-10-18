sealed class AppException implements Exception {
  const AppException();
}

final class NetworkException extends AppException {
  const NetworkException();
}

final class NotFoundException extends AppException {
  const NotFoundException();
}

final class ServerException extends AppException {
  const ServerException(this.statusCode);

  final int? statusCode;
}

final class UnexpectedException extends AppException {
  const UnexpectedException(this.cause);

  final Object cause;
}

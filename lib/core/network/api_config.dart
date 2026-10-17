abstract final class ApiConfig {
  static const String baseUrl = 'https://api.openbrewerydb.org/v1';
  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 15);
}

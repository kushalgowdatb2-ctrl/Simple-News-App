class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';
  static const String articlesEndpoint = '/articles/';
  
  static const int defaultPageSize = 15;
  static const Duration timeoutDuration = Duration(seconds: 15);
}


import '../core/constants/api_constants.dart';
import '../core/errors/api_exceptions.dart';
import '../core/network/api_client.dart';
import '../models/article.dart';
import '../models/paginated_articles.dart';
import 'article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ApiClient _apiClient;

  ArticleRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<PaginatedArticles> getArticles({
    int limit = ApiConstants.defaultPageSize,
    int offset = 0,
    String? search,
    String? newsSite,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      'ordering': '-published_at',
    };

    if (search != null && search.trim().isNotEmpty) {
      // Spaceflight News API v4 'search' parameter searches both title and summary.
      queryParams['search'] = search.trim();
    }

    if (newsSite != null && newsSite.trim().isNotEmpty && newsSite.toLowerCase() != 'all') {
      queryParams['news_site'] = newsSite.trim();
    }

    final response = await _apiClient.get(
      ApiConstants.articlesEndpoint,
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic>) {
      return PaginatedArticles.fromJson(response);
    } else {
      throw const ParseException('Unexpected response format for articles list.');
    }
  }

  @override
  Future<Article> getArticleById(int id) async {
    final response = await _apiClient.get(
      '${ApiConstants.articlesEndpoint}$id/',
    );

    if (response is Map<String, dynamic>) {
      return Article.fromJson(response);
    } else {
      throw const ParseException('Unexpected response format for article details.');
    }
  }
}


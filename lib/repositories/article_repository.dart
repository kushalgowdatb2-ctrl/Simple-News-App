import '../core/constants/api_constants.dart';
import '../models/article.dart';
import '../models/paginated_articles.dart';

abstract class ArticleRepository {
  /// Fetches a paginated list of articles.
  /// Supports optional [search] term (searching title & summary) and [newsSite] filtering.
  Future<PaginatedArticles> getArticles({
    int limit = ApiConstants.defaultPageSize,
    int offset = 0,
    String? search,
    String? newsSite,
  });

  /// Fetches an individual article by its unique [id].
  Future<Article> getArticleById(int id);
}


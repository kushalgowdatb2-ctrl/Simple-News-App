import 'article.dart';

class PaginatedArticles {
  final int count;
  final String? next;
  final String? previous;
  final List<Article> results;

  const PaginatedArticles({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  bool get hasNext => next != null && next!.isNotEmpty;

  factory PaginatedArticles.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final List<Article> parsedArticles = [];

    if (rawResults is List) {
      for (final item in rawResults) {
        if (item is Map<String, dynamic>) {
          parsedArticles.add(Article.fromJson(item));
        }
      }
    }

    return PaginatedArticles(
      count: json['count'] is int ? json['count'] as int : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: parsedArticles,
    );
  }

  PaginatedArticles copyWith({
    int? count,
    String? next,
    String? previous,
    List<Article>? results,
  }) {
    return PaginatedArticles(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }
}


import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:simple_news_app/core/network/api_client.dart';
import 'package:simple_news_app/repositories/article_repository_impl.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late ArticleRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = ArticleRepositoryImpl(apiClient: mockApiClient);
  });

  group('ArticleRepositoryImpl Tests', () {
    test('getArticles returns PaginatedArticles on success', () async {
      when(
        () => mockApiClient.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => {
          'count': 1,
          'next': null,
          'previous': null,
          'results': [
            {
              'id': 1,
              'title': 'Artemis II Core Stage Completed',
              'url': 'https://nasa.gov/artemis',
              'news_site': 'NASA',
              'summary': 'Artemis II is ready.',
            }
          ],
        },
      );

      final result = await repository.getArticles(limit: 10, offset: 0);

      expect(result.count, 1);
      expect(result.results.length, 1);
      expect(result.results.first.title, 'Artemis II Core Stage Completed');
      expect(result.hasNext, isFalse);
    });

    test('getArticleById returns single Article', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => {
          'id': 42,
          'title': 'James Webb Discovers Early Galaxy',
          'url': 'https://nasa.gov/jwst',
          'news_site': 'NASA',
          'summary': 'JWST makes new discovery.',
        },
      );

      final article = await repository.getArticleById(42);

      expect(article.id, 42);
      expect(article.title, 'James Webb Discovers Early Galaxy');
      expect(article.newsSite, 'NASA');
    });
  });
}


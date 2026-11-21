import 'package:flutter_test/flutter_test.dart';
import 'package:simple_news_app/models/article.dart';
import 'package:simple_news_app/models/paginated_articles.dart';

void main() {
  group('Article Model Tests', () {
    test('fromJson parses complete valid json correctly', () {
      final json = {
        'id': 101,
        'title': 'SpaceX Launches Starship Flight 4',
        'url': 'https://example.com/spacex',
        'image_url': 'https://example.com/image.jpg',
        'news_site': 'SpaceNews',
        'summary': 'Starship successfully launched from Starbase.',
        'published_at': '2024-06-06T12:00:00Z',
        'updated_at': '2024-06-06T13:00:00Z',
        'featured': true,
        'authors': [
          {'name': 'Elon Musk'},
        ],
      };

      final article = Article.fromJson(json);

      expect(article.id, 101);
      expect(article.title, 'SpaceX Launches Starship Flight 4');
      expect(article.url, 'https://example.com/spacex');
      expect(article.imageUrl, 'https://example.com/image.jpg');
      expect(article.newsSite, 'SpaceNews');
      expect(article.summary, 'Starship successfully launched from Starbase.');
      expect(article.publishedAt, '2024-06-06T12:00:00Z');
      expect(article.featured, true);
      expect(article.authors, ['Elon Musk']);
    });

    test('fromJson handles null and missing fields safely', () {
      final json = {
        'id': null,
        'title': null,
        'url': null,
        'image_url': null,
        'news_site': null,
        'summary': null,
        'published_at': null,
        'authors': null,
      };

      final article = Article.fromJson(json);

      expect(article.id, 0);
      expect(article.title, 'Untitled Article');
      expect(article.url, '');
      expect(article.imageUrl, isNull);
      expect(article.newsSite, 'Spaceflight News');
      expect(article.summary, 'No detailed summary provided for this article.');
      expect(article.authors, isEmpty);
    });

    test('PaginatedArticles parses json correctly', () {
      final json = {
        'count': 50,
        'next': 'https://api.spaceflightnewsapi.net/v4/articles/?limit=10&offset=10',
        'previous': null,
        'results': [
          {
            'id': 1,
            'title': 'Test 1',
            'url': 'https://example.com/1',
            'news_site': 'NASA',
            'summary': 'Summary 1',
          },
        ],
      };

      final paginated = PaginatedArticles.fromJson(json);

      expect(paginated.count, 50);
      expect(paginated.hasNext, isTrue);
      expect(paginated.results.length, 1);
      expect(paginated.results.first.title, 'Test 1');
    });
  });
}


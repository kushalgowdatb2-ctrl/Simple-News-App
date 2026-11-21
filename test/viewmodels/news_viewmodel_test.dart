import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:simple_news_app/core/errors/api_exceptions.dart';
import 'package:simple_news_app/models/article.dart';
import 'package:simple_news_app/models/paginated_articles.dart';
import 'package:simple_news_app/repositories/article_repository.dart';
import 'package:simple_news_app/viewmodels/news_viewmodel.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late MockArticleRepository mockRepository;
  late NewsViewModel viewModel;

  final sampleArticles = [
    const Article(
      id: 1,
      title: 'First Article',
      url: 'https://example.com/1',
      newsSite: 'NASA',
      summary: 'Summary 1',
    ),
    const Article(
      id: 2,
      title: 'Second Article',
      url: 'https://example.com/2',
      newsSite: 'SpaceX',
      summary: 'Summary 2',
    ),
  ];

  setUp(() {
    mockRepository = MockArticleRepository();
    viewModel = NewsViewModel(repository: mockRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('NewsViewModel Tests', () {
    test('initial state is NewsState.initial', () {
      expect(viewModel.state, NewsState.initial);
      expect(viewModel.articles, isEmpty);
      expect(viewModel.isLoading, isFalse);
    });

    test('fetchArticles sets loaded state on success', () async {
      when(
        () => mockRepository.getArticles(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          search: any(named: 'search'),
          newsSite: any(named: 'newsSite'),
        ),
      ).thenAnswer(
        (_) async => PaginatedArticles(
          count: 2,
          next: null,
          previous: null,
          results: sampleArticles,
        ),
      );

      await viewModel.fetchArticles();

      expect(viewModel.state, NewsState.loaded);
      expect(viewModel.articles.length, 2);
      expect(viewModel.articles[0].title, 'First Article');
      expect(viewModel.errorMessage, isNull);
    });

    test('fetchArticles sets empty state when results are empty', () async {
      when(
        () => mockRepository.getArticles(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          search: any(named: 'search'),
          newsSite: any(named: 'newsSite'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedArticles(
          count: 0,
          next: null,
          previous: null,
          results: [],
        ),
      );

      await viewModel.fetchArticles();

      expect(viewModel.state, NewsState.empty);
      expect(viewModel.isEmpty, isTrue);
      expect(viewModel.articles, isEmpty);
    });

    test('fetchArticles sets error state on NetworkException', () async {
      when(
        () => mockRepository.getArticles(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          search: any(named: 'search'),
          newsSite: any(named: 'newsSite'),
        ),
      ).thenThrow(const NetworkException('No internet connection.'));

      await viewModel.fetchArticles();

      expect(viewModel.state, NewsState.error);
      expect(viewModel.errorMessage, 'No internet connection.');
      expect(viewModel.articles, isEmpty);
    });

    test('loadMore appends unique articles without duplicate IDs', () async {
      when(
        () => mockRepository.getArticles(
          limit: any(named: 'limit'),
          offset: 0,
          search: any(named: 'search'),
          newsSite: any(named: 'newsSite'),
        ),
      ).thenAnswer(
        (_) async => PaginatedArticles(
          count: 3,
          next: 'next_url',
          previous: null,
          results: [sampleArticles[0]],
        ),
      );

      await viewModel.fetchArticles();
      expect(viewModel.articles.length, 1);

      when(
        () => mockRepository.getArticles(
          limit: any(named: 'limit'),
          offset: 1,
          search: any(named: 'search'),
          newsSite: any(named: 'newsSite'),
        ),
      ).thenAnswer(
        (_) async => PaginatedArticles(
          count: 3,
          next: null,
          previous: null,
          results: [sampleArticles[1]],
        ),
      );

      await viewModel.loadMore();

      expect(viewModel.articles.length, 2);
      expect(viewModel.articles[1].id, 2);
    });
  });
}


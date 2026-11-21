import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:simple_news_app/main.dart';
import 'package:simple_news_app/models/paginated_articles.dart';
import 'package:simple_news_app/repositories/article_repository.dart';
import 'package:simple_news_app/viewmodels/news_viewmodel.dart';
import 'package:simple_news_app/viewmodels/theme_viewmodel.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  testWidgets('SimpleNewsApp renders without crashing', (WidgetTester tester) async {
    final mockRepo = MockArticleRepository();
    when(
      () => mockRepo.getArticles(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        search: any(named: 'search'),
        newsSite: any(named: 'newsSite'),
      ),
    ).thenAnswer((_) async => const PaginatedArticles(count: 0, results: []));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeViewModel()),
          ChangeNotifierProvider(create: (_) => NewsViewModel(repository: mockRepo)),
        ],
        child: const SimpleNewsApp(),
      ),
    );
    expect(find.byType(SimpleNewsApp), findsOneWidget);
  });
}

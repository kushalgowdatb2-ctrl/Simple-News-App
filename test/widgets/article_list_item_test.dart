import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_news_app/models/article.dart';
import 'package:simple_news_app/views/list/widgets/article_list_item.dart';

void main() {
  testWidgets('ArticleListItem renders title, site, and published date',
      (WidgetTester tester) async {
    const article = Article(
      id: 99,
      title: 'Voyager 1 Resumes Science Operations',
      url: 'https://nasa.gov/voyager',
      newsSite: 'NASA',
      summary: 'Voyager 1 is back online.',
      publishedAt: '2024-06-15T10:00:00Z',
      authors: ['NASA JPL'],
    );

    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArticleListItem(
            article: article,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Voyager 1 Resumes Science Operations'), findsOneWidget);
    expect(find.text('NASA'), findsOneWidget);
    expect(find.text('NASA JPL'), findsOneWidget);

    await tester.tap(find.byType(ArticleListItem));
    expect(tapped, isTrue);
  });
}


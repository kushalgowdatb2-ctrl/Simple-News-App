import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/news_viewmodel.dart';
import 'article_detail_content.dart';

class ArticleDetailScreen extends StatefulWidget {
  final int initialIndex;

  const ArticleDetailScreen({super.key, required this.initialIndex});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final viewModel = context.read<NewsViewModel>();
    // Pre-fetch next page when approaching end of current list
    if (index >= viewModel.articles.length - 2 &&
        viewModel.hasMore &&
        !viewModel.isLoadingMore) {
      viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsViewModel>(
      builder: (context, viewModel, _) {
        final articles = viewModel.articles;

        if (articles.isEmpty) {
          return const Scaffold(body: Center(child: Text('No article found.')));
        }

        return Scaffold(
          body: PageView.builder(
            controller: _pageController,
            itemCount: articles.length + (viewModel.hasMore ? 1 : 0),
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              if (index < articles.length) {
                final article = articles[index];
                return ArticleDetailContent(
                  key: ValueKey('article-${article.id}'),
                  article: article,
                );
              }

              // Loading page if reached beyond current items while fetching
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        );
      },
    );
  }
}

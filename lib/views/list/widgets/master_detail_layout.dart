import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/news_viewmodel.dart';
import '../../detail/article_detail_content.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/pagination_footer.dart';
import 'article_list_item.dart';

class MasterDetailLayout extends StatelessWidget {
  final ScrollController scrollController;
  final Widget headerWidget;

  const MasterDetailLayout({
    super.key,
    required this.scrollController,
    required this.headerWidget,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NewsViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final articles = viewModel.articles;
    final selectedArticle = viewModel.selectedArticleForTablet ??
        (articles.isNotEmpty ? articles.first : null);

    return Row(
      children: [
        // Master: Article List (380px fixed width)
        SizedBox(
          width: 380,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: RefreshIndicator(
              onRefresh: viewModel.refresh,
              color: AppColors.primary,
              child: ListView.separated(
                controller: scrollController,
                itemCount: articles.length + 2, // header + items + footer
                separatorBuilder: (context, index) {
                  if (index == 0) return const SizedBox.shrink();
                  return const Divider(height: 1, indent: 16, endIndent: 16);
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return headerWidget;
                  }

                  final articleIndex = index - 1;
                  if (articleIndex < articles.length) {
                    final article = articles[articleIndex];
                    return ArticleListItem(
                      article: article,
                      isSelected: selectedArticle?.id == article.id,
                      onTap: () {
                        viewModel.selectArticle(article);
                      },
                    );
                  }

                  return PaginationFooter(
                    isLoadingMore: viewModel.isLoadingMore,
                    errorMessage: viewModel.paginationErrorMessage,
                    hasMore: viewModel.hasMore,
                    onRetry: viewModel.retryPagination,
                  );
                },
              ),
            ),
          ),
        ),

        // Detail Pane: Full Article Preview
        Expanded(
          child: selectedArticle != null
              ? ArticleDetailContent(
                  key: ValueKey('master-detail-${selectedArticle.id}'),
                  article: selectedArticle,
                  isTabletMasterDetail: true,
                )
              : const EmptyStateView(
                  title: 'Select an Article',
                  message: 'Choose any news story from the list on the left to read.',
                  icon: Icons.article_outlined,
                ),
        ),
      ],
    );
  }
}

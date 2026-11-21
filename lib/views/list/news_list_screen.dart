import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../viewmodels/news_viewmodel.dart';
import '../../../viewmodels/theme_viewmodel.dart';
import '../detail/article_detail_screen.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import '../widgets/pagination_footer.dart';
import '../widgets/shimmer_loading_list.dart';
import 'widgets/article_list_item.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/master_detail_layout.dart';
import 'widgets/search_bar_widget.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initial fetch after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsViewModel>().fetchArticles();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger next page when 250px away from bottom
    if (currentScroll >= (maxScroll - 250)) {
      context.read<NewsViewModel>().loadMore();
    }
  }

  Widget _buildHeader(BuildContext context) {
    final viewModel = context.watch<NewsViewModel>();
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar with Navigation / Theme Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () {
                    // Soft reset or clear search
                    if (_searchController.text.isNotEmpty) {
                      _searchController.clear();
                      viewModel.clearSearch();
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  themeViewModel.isDarkMode(context)
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: isDark ? Colors.amber : AppColors.textPrimaryLight,
                ),
                tooltip: 'Toggle Theme',
                onPressed: themeViewModel.toggleTheme,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Discover Headline (Inspired by reference UI)
          Text(
            AppConstants.discoverTitle,
            style: AppTextStyles.displayHeader.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.discoverSubtitle,
            style: AppTextStyles.headerSubtitle.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),

          // Search Field
          SearchBarWidget(
            controller: _searchController,
            onChanged: viewModel.onSearchQueryChanged,
            onClear: () {
              _searchController.clear();
              viewModel.clearSearch();
            },
            onFilterTap: () {
              // Open bottom sheet to choose category or sort
              _showFilterModal(context);
            },
          ),
          const SizedBox(height: 16),

          // Category Chips Bar
          CategoryFilterBar(
            selectedCategory: viewModel.selectedCategory,
            onCategorySelected: (category) {
              viewModel.selectCategory(category);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    final viewModel = context.read<NewsViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter News Site',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.categories.map((cat) {
                  final isSelected = viewModel.selectedCategory.toLowerCase() == cat.toLowerCase();
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        viewModel.selectCategory(cat);
                        Navigator.pop(ctx);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NewsViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;

            // Tablet Master-Detail Layout
            if (isTablet) {
              if (viewModel.isLoading) {
                return const ShimmerLoadingList();
              }
              if (viewModel.state == NewsState.error) {
                return ErrorStateView(
                  errorMessage: viewModel.errorMessage ?? 'An error occurred.',
                  onRetry: viewModel.retryInitial,
                );
              }
              if (viewModel.isEmpty) {
                return Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: EmptyStateView(
                        title: viewModel.searchQuery.isNotEmpty
                            ? 'No Results for "${viewModel.searchQuery}"'
                            : 'No News Available',
                        message: 'Try searching with another keyword or pick another category.',
                        actionLabel: 'Reset Filters',
                        onAction: () {
                          _searchController.clear();
                          viewModel.clearSearch();
                          viewModel.selectCategory('All');
                        },
                      ),
                    ),
                  ],
                );
              }

              return MasterDetailLayout(
                scrollController: _scrollController,
                headerWidget: _buildHeader(context),
              );
            }

            // Mobile & Smaller Tablet Layout
            return RefreshIndicator(
              onRefresh: viewModel.refresh,
              color: AppColors.primary,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // App Header Section
                  SliverToBoxAdapter(
                    child: _buildHeader(context),
                  ),

                  // State Handling: Loading Shimmer
                  if (viewModel.isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: ShimmerLoadingList(),
                    )
                  // State Handling: Full Error Screen with Retry
                  else if (viewModel.state == NewsState.error)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ErrorStateView(
                        errorMessage: viewModel.errorMessage ?? 'An error occurred.',
                        onRetry: viewModel.retryInitial,
                      ),
                    )
                  // State Handling: Empty Search / Category
                  else if (viewModel.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateView(
                        title: viewModel.searchQuery.isNotEmpty
                            ? 'No Results for "${viewModel.searchQuery}"'
                            : 'No News Available',
                        message: 'Try searching with another keyword or pick another category.',
                        actionLabel: 'Reset Filters',
                        onAction: () {
                          _searchController.clear();
                          viewModel.clearSearch();
                          viewModel.selectCategory('All');
                        },
                      ),
                    )
                  // State Handling: Loaded List with Pagination
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final article = viewModel.articles[index];
                            return ArticleListItem(
                              article: article,
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        ArticleDetailScreen(initialIndex: index),
                                    transitionsBuilder:
                                        (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          childCount: viewModel.articles.length,
                        ),
                      ),
                    ),

                    // Pagination Footer (Loading More, Error Retry, or End of feed)
                    SliverToBoxAdapter(
                      child: PaginationFooter(
                        isLoadingMore: viewModel.isLoadingMore,
                        errorMessage: viewModel.paginationErrorMessage,
                        hasMore: viewModel.hasMore,
                        onRetry: viewModel.retryPagination,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

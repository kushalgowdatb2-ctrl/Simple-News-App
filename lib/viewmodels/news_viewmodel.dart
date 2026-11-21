import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/api_exceptions.dart';
import '../core/utils/debouncer.dart';
import '../models/article.dart';
import '../repositories/article_repository.dart';

enum NewsState { initial, loading, loaded, empty, error }

class NewsViewModel extends ChangeNotifier {
  final ArticleRepository repository;
  final Debouncer _searchDebouncer;

  NewsViewModel({
    required this.repository,
    Debouncer? debouncer,
  }) : _searchDebouncer = debouncer ?? Debouncer(delay: const Duration(milliseconds: 500));

  // State
  NewsState _state = NewsState.initial;
  List<Article> _articles = [];
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  bool _hasMore = true;
  int _currentOffset = 0;
  String? _errorMessage;
  String? _paginationErrorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  Article? _selectedArticleForTablet;

  // Getters
  NewsState get state => _state;
  List<Article> get articles => List.unmodifiable(_articles);
  bool get isLoading => _state == NewsState.loading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isRefreshing => _isRefreshing;
  bool get hasMore => _hasMore;
  int get currentOffset => _currentOffset;
  String? get errorMessage => _errorMessage;
  String? get paginationErrorMessage => _paginationErrorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  Article? get selectedArticleForTablet => _selectedArticleForTablet;
  bool get isEmpty => _state == NewsState.empty || (_state == NewsState.loaded && _articles.isEmpty);

  /// Initial load or fresh load
  Future<void> fetchArticles({bool resetCategory = false}) async {
    _state = NewsState.loading;
    _errorMessage = null;
    _paginationErrorMessage = null;
    _currentOffset = 0;
    _hasMore = true;
    if (resetCategory) {
      _selectedCategory = 'All';
    }
    notifyListeners();

    try {
      final response = await repository.getArticles(
        limit: ApiConstants.defaultPageSize,
        offset: 0,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        newsSite: _selectedCategory != 'All' ? _selectedCategory : null,
      );

      _articles = response.results;
      _currentOffset = _articles.length;
      _hasMore = response.hasNext;

      if (_articles.isEmpty) {
        _state = NewsState.empty;
        _selectedArticleForTablet = null;
      } else {
        _state = NewsState.loaded;
        // Default select first article for tablet layout
        if (_selectedArticleForTablet == null || !_articles.contains(_selectedArticleForTablet)) {
          _selectedArticleForTablet = _articles.first;
        }
      }
    } on AppException catch (e) {
      _state = NewsState.error;
      _errorMessage = e.message;
    } catch (e) {
      _state = NewsState.error;
      _errorMessage = 'An unexpected error occurred while loading news.';
    } finally {
      notifyListeners();
    }
  }

  /// Pull-to-refresh
  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    _paginationErrorMessage = null;
    notifyListeners();

    try {
      final response = await repository.getArticles(
        limit: ApiConstants.defaultPageSize,
        offset: 0,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        newsSite: _selectedCategory != 'All' ? _selectedCategory : null,
      );

      _articles = response.results;
      _currentOffset = _articles.length;
      _hasMore = response.hasNext;

      if (_articles.isEmpty) {
        _state = NewsState.empty;
        _selectedArticleForTablet = null;
      } else {
        _state = NewsState.loaded;
        if (_selectedArticleForTablet == null || !_articles.contains(_selectedArticleForTablet)) {
          _selectedArticleForTablet = _articles.first;
        }
      }
      _errorMessage = null;
    } on AppException catch (e) {
      // If we already have items, keep them
      if (_articles.isEmpty) {
        _state = NewsState.error;
        _errorMessage = e.message;
      }
    } catch (_) {
      if (_articles.isEmpty) {
        _state = NewsState.error;
        _errorMessage = 'Failed to refresh articles.';
      }
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Pagination: load next batch of articles
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _state == NewsState.loading || _isRefreshing) {
      return;
    }

    _isLoadingMore = true;
    _paginationErrorMessage = null;
    notifyListeners();

    try {
      final response = await repository.getArticles(
        limit: ApiConstants.defaultPageSize,
        offset: _currentOffset,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        newsSite: _selectedCategory != 'All' ? _selectedCategory : null,
      );

      final newArticles = response.results;
      final existingIds = _articles.map((e) => e.id).toSet();
      final filteredNewArticles = newArticles.where((a) => !existingIds.contains(a.id)).toList();

      _articles = [..._articles, ...filteredNewArticles];
      _currentOffset = _articles.length;
      _hasMore = response.hasNext;
      _paginationErrorMessage = null;
    } on AppException catch (e) {
      _paginationErrorMessage = e.message;
    } catch (_) {
      _paginationErrorMessage = 'Failed to load more articles. Please tap retry.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// User updates search query with debouncer
  void onSearchQueryChanged(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;

    _searchDebouncer.run(() {
      fetchArticles();
    });
  }

  /// Clear active search
  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    _searchDebouncer.cancel();
    fetchArticles();
  }

  /// Change category filter
  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchArticles();
  }

  /// Select article for Master-Detail view on tablets/iPads
  void selectArticle(Article? article) {
    _selectedArticleForTablet = article;
    notifyListeners();
  }

  /// Retry action when full load failed
  void retryInitial() {
    fetchArticles();
  }

  /// Retry pagination load
  void retryPagination() {
    loadMore();
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }
}

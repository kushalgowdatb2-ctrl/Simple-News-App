import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/url_helper.dart';
import '../../models/article.dart';
import '../widgets/app_image.dart';

class ArticleDetailContent extends StatefulWidget {
  final Article article;
  final bool isTabletMasterDetail;
  final VoidCallback? onBack;

  const ArticleDetailContent({
    super.key,
    required this.article,
    this.isTabletMasterDetail = false,
    this.onBack,
  });

  @override
  State<ArticleDetailContent> createState() => _ArticleDetailContentState();
}

class _ArticleDetailContentState extends State<ArticleDetailContent> {
  bool _isBookmarked = false;

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked ? 'Article saved to bookmarks' : 'Article removed from bookmarks',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareArticle() {
    final title = widget.article.title;
    final url = widget.article.url;
    Share.share(
      '$title\n\nRead more at: $url',
      subject: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final article = widget.article;
    final sourceName = article.newsSite;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Header Image with floating buttons & title overlay
          SliverAppBar(
            expandedHeight: widget.isTabletMasterDetail ? 300 : 360,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Image
                  Hero(
                    tag: 'article-image-${article.id}',
                    child: AppImage(
                      imageUrl: article.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Dark gradient overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                          Colors.black.withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // Bottom text overlay inside image
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            article.newsSite,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Title
                        Text(
                          article.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Subtitle: Trending / Time
                        Row(
                          children: [
                            Text(
                              article.featured ? 'Featured' : 'Trending',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              '  •  ',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              DateFormatter.formatRelativeTime(article.publishedAt),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Top overlay action buttons
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        if (!widget.isTabletMasterDetail)
                          _CircleButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: widget.onBack ?? () => Navigator.of(context).pop(),
                          )
                        else
                          const SizedBox.shrink(),
                        Row(
                          children: [
                            _CircleButton(
                              icon: _isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_outline_rounded,
                              iconColor: _isBookmarked ? AppColors.primary : Colors.white,
                              onTap: _toggleBookmark,
                            ),
                            const SizedBox(width: 10),
                            _CircleButton(
                              icon: Icons.share_rounded,
                              onTap: _shareArticle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Article Body Container
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Publisher Identity Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                        child: Text(
                          sourceName.isNotEmpty ? sourceName[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    sourceName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.verifiedBlue,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Published ${DateFormatter.formatFriendlyDate(article.publishedAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 20),

                  // Article Full Summary / Content
                  Text(
                    article.summary,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : const Color(0xFF374151),
                      letterSpacing: 0.1,
                    ),
                  ),

                  // Authors info if available
                  if (article.authors.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Written by ${article.authors.join(', ')}',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],

                  const SizedBox(height: 36),

                  // "Read full article" Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => UrlHelper.launchArticleUrl(article.url),
                      icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                      label: const Text(
                        'Read full article',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}

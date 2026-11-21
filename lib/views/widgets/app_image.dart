import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class AppImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackWidget = Container(
      width: width,
      height: height,
      color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F3F9),
      child: Center(
        child: Icon(
          Icons.rocket_launch_rounded,
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          size: (width != null && width! < 60) ? 20 : 32,
        ),
      ),
    );

    Widget imageWidget;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      imageWidget = fallbackWidget;
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl!.trim(),
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
          highlightColor: isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlight,
          child: Container(
            width: width,
            height: height,
            color: isDark ? AppColors.surfaceDark : Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => fallbackWidget,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}


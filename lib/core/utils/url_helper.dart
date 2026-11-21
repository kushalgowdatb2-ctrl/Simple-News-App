import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  UrlHelper._();

  /// Safely launches the article URL in external browser.
  static Future<bool> launchArticleUrl(String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) {
      return false;
    }

    try {
      final uri = Uri.parse(urlString.trim());
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}


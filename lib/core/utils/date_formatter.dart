import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Formats ISO date to readable string, e.g. "Feb 27, 2023"
  static String formatFriendlyDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Recent';
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return 'Recent';
    }
  }

  /// Formats ISO date to relative string, e.g. "6 hours ago" or "2 days ago"
  static String formatRelativeTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Recently';
    try {
      final date = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.isNegative) {
        return 'Just now';
      }

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        final minutes = difference.inMinutes;
        return '$minutes ${minutes == 1 ? "minute" : "minutes"} ago';
      } else if (difference.inHours < 24) {
        final hours = difference.inHours;
        return '$hours ${hours == 1 ? "hour" : "hours"} ago';
      } else if (difference.inDays < 7) {
        final days = difference.inDays;
        return '$days ${days == 1 ? "day" : "days"} ago';
      } else {
        return DateFormat('MMM d, yyyy').format(date);
      }
    } catch (_) {
      return 'Recently';
    }
  }
}


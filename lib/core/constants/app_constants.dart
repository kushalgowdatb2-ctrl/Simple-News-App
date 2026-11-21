class AppConstants {
  AppConstants._();

  static const String appTitle = 'Simple News';
  static const String discoverTitle = 'Discover';
  static const String discoverSubtitle = 'News from all around the world';
  static const String searchHint = 'Search news by title or summary...';

  // Responsive Breakpoints (in logical pixels)
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;

  // Filter Categories / News Sites for Discover bar
  static const List<String> categories = [
    'All',
    'NASA',
    'SpaceNews',
    'SpaceX',
    'ESA',
    'Teslarati',
    'Space.com',
    'Ars Technica',
    'European Spaceflight',
  ];
}


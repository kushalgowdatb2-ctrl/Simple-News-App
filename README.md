# Simple News App (Flutter)

A modern, responsive, production-ready News application built with Flutter, powered by the [Spaceflight News API (SNAPI v4)](https://api.spaceflightnewsapi.net/v4/docs/).

The app follows the **MVVM (Model - View - ViewModel)** architectural pattern, supports **Android, iOS, Tablets, and iPads**, and faithfully replicates the reference UI design while delivering production-grade reliability, graceful error recovery, and seamless swipe navigation.

---

## 📱 Features & Highlights

### 1. List Screen (Discover Feed)
- **Reference UI Match**: Clean top app bar with "Discover" title, subtle subtitle, search bar with search/filter icons, and horizontal category chips.
- **Search with Debounce**: Fast, client-debounced search (500ms delay) that queries the Spaceflight News API by title or summary without hammering the network. Includes a quick clear button (`X`).
- **Category Filter**: Filter stories by popular news providers (e.g., NASA, SpaceX, SpaceNews, ESA, Space.com, Teslarati, etc.) or choose "All".
- **Infinite Scroll Pagination**: Automatically loads the next batch of articles as the user scrolls within 250px of the bottom. Includes duplicate prevention guards.
- **Pagination Error Recovery**: If loading more items fails (e.g. temporary packet drop), a friendly retry footer appears at the bottom without clearing the already loaded articles.
- **Pull to Refresh**: Smooth `RefreshIndicator` that reloads the feed from offset 0.
- **Rich Article Cards**: Thumbnail with rounded corners, news site pill, 2-line headline, source avatar, source name, and formatted publication date.

### 2. Detail Screen (Reader Experience)
- **Hero Image & Actions**: Parallax header image with Hero animation, circular back button, toggleable bookmark button with feedback, and native system share.
- **Detailed Metadata**: Category badge, headline, trending/relative timestamp ("Trending • 6 hours ago"), publisher logo with verified badge, and full summary.
- **"Read full article" Action**: Direct button launching the original source website in an external browser via `url_launcher`.
- **Gmail-Style Swipe Navigation**: Users can swipe left or right using a `PageView` to browse preceding and subsequent articles seamlessly.
- **Endless Swiping**: When approaching the end of the loaded articles in the reader, the app pre-fetches the next page in the background so reading is never interrupted.

### 3. Responsive Layout (Phones, Tablets & iPads)
- Built using `LayoutBuilder` and `MediaQuery`.
- **Phones (< 900px)**: Single-column scrollable feed with animated push navigation to the reader screen.
- **Tablets & iPads (≥ 900px)**: **Master-Detail split view** featuring the discover list on the left pane and an interactive full-article reader on the right pane.

### 4. Robust Production Scenarios Handled
- **Offline & Timeout Handling**: Detects `SocketException` and `TimeoutException`, displaying a dedicated "Connection Lost" screen with a retry button.
- **Shimmer Skeletons**: Polished placeholder loading skeletons (`shimmer`) matching the real layout.
- **Empty States**: Customized empty states for both no data and no search results with a one-tap reset.
- **Null Safety & Missing Fields**: Graceful fallbacks for missing images, empty summaries, null authors, or missing dates.
- **Dark Mode Support**: Full light and dark theme palette with dynamic system brightness detection and a one-click manual switcher.
- **Text Scaling**: Layouts, cards, and titles respect system accessibility text scaling without clipping or overflow.
- **Memory Leak Protection**: Proper disposal of `ScrollController`, `TextEditingController`, `PageController`, and `Debouncer`.

---

## 🏛️ Architecture Overview (MVVM)

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart      # Base URLs, endpoints, timeouts, page size
│   │   └── app_constants.dart      # Breakpoints, category names, copy text
│   ├── errors/
│   │   └── api_exceptions.dart     # Typed exceptions (Network, Timeout, Server, NotFound)
│   ├── network/
│   │   └── api_client.dart         # HTTP wrapper with timeout and typed error mapping
│   ├── theme/
│   │   ├── app_colors.dart         # Consistent light & dark palette
│   │   ├── app_text_styles.dart    # Typography scale
│   │   └── app_theme.dart          # Light and dark ThemeData
│   └── utils/
│       ├── date_formatter.dart     # Friendly ("Feb 27, 2023") & relative ("6 hours ago") dates
│       ├── debouncer.dart          # Timer debouncer for search
│       └── url_helper.dart         # Safe URL launcher helper
├── models/
│   ├── article.dart                # Article entity with fromJson & null-safe fallbacks
│   └── paginated_articles.dart     # Paginated response wrapper with count & next pointer
├── repositories/
│   ├── article_repository.dart     # Abstract repository contract
│   └── article_repository_impl.dart# Repository implementation using ApiClient
├── viewmodels/
│   ├── news_viewmodel.dart         # News state, search, filter, pagination, error handling
│   └── theme_viewmodel.dart        # Theme mode state management (light / dark / system)
├── views/
│   ├── detail/
│   │   ├── article_detail_content.dart # Reusable detail content (used in mobile & tablet)
│   │   └── article_detail_screen.dart  # PageView reader for swipe navigation
│   ├── list/
│   │   ├── news_list_screen.dart   # Main discover screen with responsive branching
│   │   └── widgets/
│   │       ├── article_list_item.dart  # News feed card with Hero thumbnail
│   │       ├── category_filter_bar.dart# Horizontal scrolling category chips
│   │       ├── master_detail_layout.dart# Tablet/iPad split view layout
│   │       └── search_bar_widget.dart  # Discover search field with clear & filter
│   └── widgets/
│       ├── app_image.dart          # CachedNetworkImage with shimmer & error fallback
│       ├── empty_state_view.dart   # Reusable empty state with reset button
│       ├── error_state_view.dart   # Reusable error view with retry action
│       ├── pagination_footer.dart  # Loader / retry footer for pagination
│       └── shimmer_loading_list.dart# Skeletons for initial loading
└── main.dart                       # Entry point, MultiProvider configuration
```

---

## ⚖️ State Management Justification

**Chosen Solution**: `Provider` with `ChangeNotifier`

### Why Provider for this application?
1. **Pristine MVVM Separation**: `NewsViewModel` extends `ChangeNotifier`, keeping UI logic completely separate from the presentation layer. The View only observes state and sends user intents.
2. **Official Flutter Recommended Standard**: Provider is lightweight, native-feeling, and avoids unnecessary code generation or heavy boilerplate.
3. **Testability**: Because `NewsViewModel` takes an `ArticleRepository` abstraction in its constructor, we can mock the repository with zero friction in unit tests without configuring complex streams or container overrides.
4. **Efficiency**: Fine-grained updates with `context.watch<NewsViewModel>()` and `context.select(...)` prevent unnecessary widget rebuilds.

---

## 📦 Packages Used

| Package | Version | Purpose |
|---|---|---|
| `provider` | `^6.1.2` | State management implementing the MVVM pattern |
| `http` | `^1.2.2` | Lightweight HTTP client for Spaceflight News API calls |
| `cached_network_image` | `^3.4.1` | Efficient image caching, memory management, and disk cache |
| `shimmer` | `^3.0.0` | Polished skeleton loading effects matching card geometry |
| `intl` | `^0.19.0` | Publication date formatting (relative time and standard date) |
| `url_launcher` | `^6.3.1` | Opening the original article in the external browser |
| `share_plus` | `^10.1.3` | Native device share sheet integration |
| `mocktail` (dev) | `^1.0.4` | Clean null-safe mocking for unit and repository tests |
| `flutter_lints` (dev) | `^6.0.0` | Official Dart & Flutter linting rules |

---

## 🚀 Setup & Running Instructions

### Prerequisites
- Flutter SDK `^3.19.0` or higher
- Android Studio / VS Code with Flutter extension
- Connected physical device, Android Emulator, iOS Simulator, or Chrome/Desktop

### 1. Clone the repository
```bash
git clone https://github.com/kushalgowdatb2-ctrl/Simple-News-App.git
cd simple_news_app
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run Static Analysis (Linter check)
```bash
flutter analyze
```
*(Ensures 0 errors and clean code style).*

### 4. Run the Test Suite
```bash
flutter test --no-pub
```
*(Executes all unit tests for models, repositories, viewmodels, and widget tests).*

### 5. Run the Application
```bash
# Run on the connected device or emulator
flutter run

# Or target specific platforms:
flutter run -d chrome
flutter run -d windows
flutter run -d android
```

---

## 📐 Assumptions & Design Adaptations
1. **API Mapping**: As noted in the specification, the Spaceflight News API does not provide author avatars or a separate "category" taxonomy. We adapted `news_site` to serve as the category pill and publisher branding (e.g. NASA, SpaceNews, SpaceX).
2. **Search API**: Spaceflight News API v4 supports the `search` query parameter which searches across both `title` and `summary`, meeting the user search criteria.
3. **Tablet Experience**: For screens with width ≥ 900dp (tablets, iPads, foldables, and desktop windows), a Master-Detail split view is automatically presented.

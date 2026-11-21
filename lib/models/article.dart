class Article {
  final int id;
  final String title;
  final String url;
  final String? imageUrl;
  final String newsSite;
  final String summary;
  final String? publishedAt;
  final String? updatedAt;
  final bool featured;
  final List<String> authors;

  const Article({
    required this.id,
    required this.title,
    required this.url,
    this.imageUrl,
    required this.newsSite,
    required this.summary,
    this.publishedAt,
    this.updatedAt,
    this.featured = false,
    this.authors = const [],
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    // Parse author names gracefully from either string list or object list
    final List<String> parsedAuthors = [];
    if (json['authors'] is List) {
      for (final a in json['authors']) {
        if (a is Map && a.containsKey('name') && a['name'] != null) {
          parsedAuthors.add(a['name'].toString());
        } else if (a is String) {
          parsedAuthors.add(a);
        }
      }
    }

    return Article(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Untitled Article',
      url: (json['url'] as String?) ?? '',
      imageUrl: (json['image_url'] as String?)?.trim().isNotEmpty == true
          ? (json['image_url'] as String).trim()
          : null,
      newsSite: (json['news_site'] as String?)?.trim().isNotEmpty == true
          ? (json['news_site'] as String).trim()
          : 'Spaceflight News',
      summary: (json['summary'] as String?)?.trim().isNotEmpty == true
          ? (json['summary'] as String).trim()
          : 'No detailed summary provided for this article.',
      publishedAt: json['published_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      featured: json['featured'] as bool? ?? false,
      authors: parsedAuthors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'image_url': imageUrl,
      'news_site': newsSite,
      'summary': summary,
      'published_at': publishedAt,
      'updated_at': updatedAt,
      'featured': featured,
      'authors': authors.map((name) => {'name': name}).toList(),
    };
  }

  Article copyWith({
    int? id,
    String? title,
    String? url,
    String? imageUrl,
    String? newsSite,
    String? summary,
    String? publishedAt,
    String? updatedAt,
    bool? featured,
    List<String>? authors,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      newsSite: newsSite ?? this.newsSite,
      summary: summary ?? this.summary,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      featured: featured ?? this.featured,
      authors: authors ?? this.authors,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}


import '../../../core/config/app_env.dart';

class Comic {
  final int id;
  final String title;
  final String slug;
  final String? coverImageUrl;
  final String? bannerImageUrl;
  final String? summary;
  final String? authorName;
  final String? publicationStatus;
  final String? visibilityStatus;
  final String? ageRating;
  final int totalChapters;
  final int totalViews;
  final int totalFollows;
  final String? genres;
  final bool isFollowing;

  Comic({
    required this.id,
    required this.title,
    required this.slug,
    this.coverImageUrl,
    this.bannerImageUrl,
    this.summary,
    this.authorName,
    this.publicationStatus,
    this.visibilityStatus,
    this.ageRating,
    required this.totalChapters,
    required this.totalViews,
    required this.totalFollows,
    this.genres,
    this.isFollowing = false,
  });

  factory Comic.fromMap(Map<String, dynamic> map) {
    return Comic(
      id: _toInt(map['id']),
      title: (map['title'] ?? '').toString(),
      slug: (map['slug'] ?? '').toString(),
      coverImageUrl: _buildFullImageUrl(
        (map['cover_image_url'] ?? map['coverImageUrl'])?.toString(),
      ),
      bannerImageUrl: _buildFullImageUrl(
        (map['banner_image_url'] ?? map['bannerImageUrl'])?.toString(),
      ),
      summary: map['summary']?.toString(),
      authorName: (map['author_name'] ?? map['authorName'])?.toString(),
      publicationStatus:
      (map['publication_status'] ?? map['publicationStatus'])?.toString(),
      visibilityStatus:
      (map['visibility_status'] ?? map['visibilityStatus'])?.toString(),
      ageRating: (map['age_rating'] ?? map['ageRating'])?.toString(),
      totalChapters: _toInt(map['total_chapters'] ?? map['totalChapters']),
      totalViews: _toInt(map['total_views'] ?? map['totalViews']),
      totalFollows: _toInt(map['total_follows'] ?? map['totalFollows']),
      genres: map['genres']?.toString(),
      isFollowing: _toBool(
        map['is_following'] ?? map['isFollowing'] ?? map['followed'],
      ),
    );
  }

  Comic copyWith({
    int? id,
    String? title,
    String? slug,
    String? coverImageUrl,
    String? bannerImageUrl,
    String? summary,
    String? authorName,
    String? publicationStatus,
    String? visibilityStatus,
    String? ageRating,
    int? totalChapters,
    int? totalViews,
    int? totalFollows,
    String? genres,
    bool? isFollowing,
  }) {
    return Comic(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      summary: summary ?? this.summary,
      authorName: authorName ?? this.authorName,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      visibilityStatus: visibilityStatus ?? this.visibilityStatus,
      ageRating: ageRating ?? this.ageRating,
      totalChapters: totalChapters ?? this.totalChapters,
      totalViews: totalViews ?? this.totalViews,
      totalFollows: totalFollows ?? this.totalFollows,
      genres: genres ?? this.genres,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is num) return value.toInt() == 1;

    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }

  static String? _buildFullImageUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    final normalized = raw.replaceAll('\\', '/');
    final mediaBaseUrl = AppEnv.baseUrl.replaceFirst('/api', '');

    if (normalized.startsWith('/')) {
      return '$mediaBaseUrl$normalized';
    }

    return '$mediaBaseUrl/$normalized';
  }
}
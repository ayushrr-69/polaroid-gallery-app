import 'photo.dart';

/// A named collection of [Photo]s.
class Album {
  const Album({
    required this.id,
    required this.title,
    required this.photos,
    this.coverImageUrl,
  });

  final String id;
  final String title;
  final List<Photo> photos;

  /// Optional override — falls back to first photo's image.
  final String? coverImageUrl;

  int get photoCount => photos.length;

  String get displayCover =>
      coverImageUrl ?? (photos.isNotEmpty ? photos.first.imageUrl : '');

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'photos': photos.map((p) => p.toJson()).toList(),
        'coverImageUrl': coverImageUrl,
      };

  factory Album.fromJson(Map<String, dynamic> json) => Album(
        id: json['id'] as String,
        title: json['title'] as String,
        photos: (json['photos'] as List<dynamic>?)
                ?.map((p) => Photo.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
        coverImageUrl: json['coverImageUrl'] as String?,
      );
}

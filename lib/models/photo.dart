/// A single photo in the gallery.
class Photo {
  const Photo({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.isFavorite = false,
    this.location,
    this.shutterSpeed,
    required this.date,
    this.aspectRatio = 1.0,
    this.caption,
  });

  final String id;
  final String title;
  final String imageUrl;
  final bool isFavorite;
  final String? location;
  final String? shutterSpeed;
  final DateTime date;
  final String? caption;

  /// Width / height ratio — used for masonry grid sizing.
  final double aspectRatio;

  Photo copyWith({bool? isFavorite}) => Photo(
    id: id,
    title: title,
    imageUrl: imageUrl,
    isFavorite: isFavorite ?? this.isFavorite,
    location: location,
    shutterSpeed: shutterSpeed,
    date: date,
    aspectRatio: aspectRatio,
    caption: caption,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'imageUrl': imageUrl,
        'isFavorite': isFavorite,
        'location': location,
        'shutterSpeed': shutterSpeed,
        'date': date.toIso8601String(),
        'caption': caption,
        'aspectRatio': aspectRatio,
      };

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        id: json['id'] as String,
        title: json['title'] as String,
        imageUrl: json['imageUrl'] as String,
        isFavorite: json['isFavorite'] as bool? ?? false,
        location: json['location'] as String?,
        shutterSpeed: json['shutterSpeed'] as String?,
        date: DateTime.parse(json['date'] as String),
        caption: json['caption'] as String?,
        aspectRatio: (json['aspectRatio'] as num?)?.toDouble() ?? 1.0,
      );
}

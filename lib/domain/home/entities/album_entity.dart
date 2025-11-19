class AlbumEntity {
  final String id;
  final String title;
  final String? artist;
  final String thumbnailUrl;

  AlbumEntity({
    required this.id,
    required this.title,
    this.artist,
    required this.thumbnailUrl,
  });
}

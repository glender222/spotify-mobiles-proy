class TrackEntity {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? thumbnailUrl;
  final Duration? duration;

  TrackEntity({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.thumbnailUrl,
    this.duration,
  });
}

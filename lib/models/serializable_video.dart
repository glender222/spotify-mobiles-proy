class SerializableVideo {
  final String id;
  final String title;
  final String artist;
  final String thumbnailUrl;

  SerializableVideo({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory SerializableVideo.fromJson(Map<String, dynamic> json) {
    return SerializableVideo(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}

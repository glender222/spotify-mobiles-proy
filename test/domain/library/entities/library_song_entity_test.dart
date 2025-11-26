import 'package:flutter_test/flutter_test.dart';
import 'package:audio_service/audio_service.dart';
import 'package:harmonymusic/domain/library/entities/library_song_entity.dart';

void main() {
  group('LibrarySongEntity', () {
    final testSongEntity = LibrarySongEntity(
      id: 'song123',
      title: 'Test Song',
      addedAt: DateTime(2024, 1, 1),
      artist: 'Test Artist',
      album: 'Test Album',
      duration: const Duration(minutes: 3, seconds: 30),
      thumbnailUrl: 'https://example.com/thumb.jpg',
      isDownloaded: true,
      isCached: false,
      localPath: '/path/to/song.mp3',
      extras: {'genre': 'Rock'},
    );

    test('should create entity with all properties', () {
      expect(testSongEntity.id, 'song123');
      expect(testSongEntity.title, 'Test Song');
      expect(testSongEntity.artist, 'Test Artist');
      expect(testSongEntity.album, 'Test Album');
      expect(testSongEntity.duration, const Duration(minutes: 3, seconds: 30));
      expect(testSongEntity.isDownloaded, true);
      expect(testSongEntity.isCached, false);
    });

    test('should serialize to JSON correctly', () {
      final json = testSongEntity.toJson();

      expect(json['id'], 'song123');
      expect(json['title'], 'Test Song');
      expect(json['artist'], 'Test Artist');
      expect(json['album'], 'Test Album');
      expect(json['duration'], 210000); // 3:30 in milliseconds
      expect(json['thumbnailUrl'], 'https://example.com/thumb.jpg');
      expect(json['isDownloaded'], true);
      expect(json['isCached'], false);
      expect(json['localPath'], '/path/to/song.mp3');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'song456',
        'title': 'Another Song',
        'addedAt': '2024-02-01T00:00:00.000',
        'artist': 'Another Artist',
        'album': 'Another Album',
        'duration': 180000, // 3 minutes
        'thumbnailUrl': 'https://example.com/thumb2.jpg',
        'isDownloaded': false,
        'isCached': true,
        'localPath': null,
        'extras': {'genre': 'Pop'},
      };

      final entity = LibrarySongEntity.fromJson(json);

      expect(entity.id, 'song456');
      expect(entity.title, 'Another Song');
      expect(entity.artist, 'Another Artist');
      expect(entity.duration, const Duration(minutes: 3));
      expect(entity.isDownloaded, false);
      expect(entity.isCached, true);
    });

    test('should convert to MediaItem correctly', () {
      final mediaItem = testSongEntity.toMediaItem();

      expect(mediaItem.id, 'song123');
      expect(mediaItem.title, 'Test Song');
      expect(mediaItem.artist, 'Test Artist');
      expect(mediaItem.album, 'Test Album');
      expect(mediaItem.duration, const Duration(minutes: 3, seconds: 30));
      expect(mediaItem.extras?['isDownloaded'], true);
      expect(mediaItem.extras?['url'], '/path/to/song.mp3');
    });

    test('should convert from MediaItem correctly', () {
      final mediaItem = MediaItem(
        id: 'media789',
        title: 'Media Song',
        artist: 'Media Artist',
        album: 'Media Album',
        duration: const Duration(minutes: 4),
        artUri: Uri.parse('https://example.com/art.jpg'),
        extras: {
          'isDownloaded': true,
          'url': '/media/path.mp3',
        },
      );

      final entity = LibrarySongEntity.fromMediaItem(mediaItem);

      expect(entity.id, 'media789');
      expect(entity.title, 'Media Song');
      expect(entity.artist, 'Media Artist');
      expect(entity.album, 'Media Album');
      expect(entity.isDownloaded, true);
      expect(entity.localPath, '/media/path.mp3');
    });

    test('should create copy with updated fields', () {
      final updated = testSongEntity.copyWith(
        title: 'Updated Title',
        isDownloaded: false,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.isDownloaded, false);
      // Other fields should remain the same
      expect(updated.id, 'song123');
      expect(updated.artist, 'Test Artist');
    });

    test('should handle null optional fields', () {
      final minimalEntity = LibrarySongEntity(
        id: 'minimal',
        title: 'Minimal Song',
        addedAt: DateTime.now(),
        artist: 'Artist',
        thumbnailUrl: '',
      );

      expect(minimalEntity.album, null);
      expect(minimalEntity.duration, null);
      expect(minimalEntity.localPath, null);
      expect(minimalEntity.isDownloaded, false);
      expect(minimalEntity.isCached, false);
    });
  });
}

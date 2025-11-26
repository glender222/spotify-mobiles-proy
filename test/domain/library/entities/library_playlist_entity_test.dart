import 'package:flutter_test/flutter_test.dart';
import 'package:harmonymusic/domain/library/entities/library_playlist_entity.dart';
import 'package:harmonymusic/models/playlist.dart';

void main() {
  group('LibraryPlaylistEntity', () {
    final testPlaylistEntity = LibraryPlaylistEntity(
      id: 'playlist123',
      title: 'My Playlist',
      addedAt: DateTime(2024, 1, 1),
      description: 'Test playlist description',
      thumbnailUrl: 'https://example.com/playlist.jpg',
      isCloudPlaylist: false,
      isPipedPlaylist: false,
      songCount: 10,
    );

    test('should create entity with all properties', () {
      expect(testPlaylistEntity.id, 'playlist123');
      expect(testPlaylistEntity.title, 'My Playlist');
      expect(testPlaylistEntity.description, 'Test playlist description');
      expect(testPlaylistEntity.isCloudPlaylist, false);
      expect(testPlaylistEntity.isPipedPlaylist, false);
      expect(testPlaylistEntity.songCount, 10);
    });

    test('should serialize to JSON correctly', () {
      final json = testPlaylistEntity.toJson();

      expect(json['playlistId'], 'playlist123');
      expect(json['title'], 'My Playlist');
      expect(json['description'], 'Test playlist description');
      expect(json['thumbnailUrl'], 'https://example.com/playlist.jpg');
      expect(json['isCloudPlaylist'], false);
      expect(json['isPipedPlaylist'], false);
      expect(json['songCount'], 10);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'playlistId': 'playlist456',
        'title': 'Another Playlist',
        'addedAt': '2024-02-01T00:00:00.000',
        'description': 'Another description',
        'thumbnailUrl': 'https://example.com/playlist2.jpg',
        'isCloudPlaylist': true,
        'isPipedPlaylist': true,
        'songCount': 5,
      };

      final entity = LibraryPlaylistEntity.fromJson(json);

      expect(entity.id, 'playlist456');
      expect(entity.title, 'Another Playlist');
      expect(entity.isCloudPlaylist, true);
      expect(entity.isPipedPlaylist, true);
      expect(entity.songCount, 5);
    });

    test('should convert to Playlist model correctly', () {
      final playlist = testPlaylistEntity.toPlaylist();

      expect(playlist.playlistId, 'playlist123');
      expect(playlist.title, 'My Playlist');
      expect(playlist.description, 'Test playlist description');
      expect(playlist.thumbnailUrl, 'https://example.com/playlist.jpg');
      expect(playlist.isCloudPlaylist, false);
      expect(playlist.isPipedPlaylist, false);
    });

    test('should convert from Playlist model correctly', () {
      final playlist = Playlist(
        playlistId: 'model123',
        title: 'Model Playlist',
        thumbnailUrl: 'https://example.com/model.jpg',
        description: 'From model',
        isCloudPlaylist: true,
        isPipedPlaylist: false,
      );

      final entity = LibraryPlaylistEntity.fromPlaylist(playlist);

      expect(entity.id, 'model123');
      expect(entity.title, 'Model Playlist');
      expect(entity.description, 'From model');
      expect(entity.isCloudPlaylist, true);
      expect(entity.isPipedPlaylist, false);
    });

    test('should create copy with updated fields', () {
      final updated = testPlaylistEntity.copyWith(
        title: 'Updated Playlist',
        songCount: 20,
      );

      expect(updated.title, 'Updated Playlist');
      expect(updated.songCount, 20);
      expect(updated.id, 'playlist123');
      expect(updated.description, 'Test playlist description');
    });

    test('should handle defaults for missing JSON fields', () {
      final json = {
        'playlistId': 'minimal',
        'title': 'Minimal Playlist',
        'thumbnailUrl': 'url',
      };

      final entity = LibraryPlaylistEntity.fromJson(json);

      expect(entity.isCloudPlaylist, false);
      expect(entity.isPipedPlaylist, false);
      expect(entity.songCount, 0);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:harmonymusic/domain/library/repository/library_repository.dart';
import 'package:harmonymusic/domain/library/usecases/get_library_playlists_usecase.dart';
import 'package:harmonymusic/domain/library/entities/library_playlist_entity.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';

import 'get_library_songs_usecase_test.mocks.dart';

@GenerateMocks([LibraryRepository])
void main() {
  late MockLibraryRepository mockRepository;
  late GetLibraryPlaylistsUseCase useCase;

  setUp(() {
    mockRepository = MockLibraryRepository();
    Get.put<LibraryRepository>(mockRepository);
    useCase = GetLibraryPlaylistsUseCase();
  });

  tearDown(() {
    Get.reset();
  });

  group('GetLibraryPlaylistsUseCase', () {
    final testPlaylists = [
      LibraryPlaylistEntity(
        id: 'playlist1',
        title: 'Playlist 1',
        addedAt: DateTime.now(),
        thumbnailUrl: 'url1',
      ),
      LibraryPlaylistEntity(
        id: 'playlist2',
        title: 'Playlist 2',
        addedAt: DateTime.now(),
        thumbnailUrl: 'url2',
        isPipedPlaylist: true,
      ),
    ];

    test('should return list of playlists from repository', () async {
      // Arrange
      when(mockRepository.getLibraryPlaylists())
          .thenAnswer((_) async => testPlaylists);

      // Act
      final result = await useCase();

      // Assert
      expect(result, testPlaylists);
      expect(result.length, 2);
      verify(mockRepository.getLibraryPlaylists()).called(1);
    });

    test('should return empty list when no playlists', () async {
      // Arrange
      when(mockRepository.getLibraryPlaylists()).thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getLibraryPlaylists()).called(1);
    });

    test('should propagate exception from repository', () async {
      // Arrange
      when(mockRepository.getLibraryPlaylists())
          .thenThrow(LibraryException('Failed to get playlists'));

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(isA<LibraryException>()),
      );
    });
  });
}

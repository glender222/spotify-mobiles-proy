import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:harmonymusic/domain/library/repository/library_repository.dart';
import 'package:harmonymusic/domain/library/usecases/create_playlist_usecase.dart';
import 'package:harmonymusic/domain/library/entities/library_playlist_entity.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';

import 'get_library_songs_usecase_test.mocks.dart';

@GenerateMocks([LibraryRepository])
void main() {
  late MockLibraryRepository mockRepository;
  late CreatePlaylistUseCase useCase;

  setUp(() {
    mockRepository = MockLibraryRepository();
    Get.put<LibraryRepository>(mockRepository);
    useCase = CreatePlaylistUseCase();
  });

  tearDown(() {
    Get.reset();
  });

  group('CreatePlaylistUseCase', () {
    final testPlaylist = LibraryPlaylistEntity(
      id: 'new_playlist',
      title: 'New Playlist',
      addedAt: DateTime.now(),
      thumbnailUrl: 'url',
    );

    test('should create playlist without syncing to Piped', () async {
      // Arrange
      when(mockRepository.createPlaylist(any, syncToPiped: false))
          .thenAnswer((_) async => {});

      // Act
      await useCase(testPlaylist, syncToPiped: false);

      // Assert
      verify(mockRepository.createPlaylist(testPlaylist, syncToPiped: false))
          .called(1);
    });

    test('should create playlist and sync to Piped when requested', () async {
      // Arrange
      when(mockRepository.createPlaylist(any, syncToPiped: true))
          .thenAnswer((_) async => {});

      // Act
      await useCase(testPlaylist, syncToPiped: true);

      // Assert
      verify(mockRepository.createPlaylist(testPlaylist, syncToPiped: true))
          .called(1);
    });

    test('should propagate exception from repository', () async {
      // Arrange
      when(mockRepository.createPlaylist(any,
              syncToPiped: anyNamed('syncToPiped')))
          .thenThrow(LibraryException('Failed to create playlist'));

      // Act & Assert
      expect(
        () => useCase(testPlaylist),
        throwsA(isA<LibraryException>()),
      );
    });
  });
}

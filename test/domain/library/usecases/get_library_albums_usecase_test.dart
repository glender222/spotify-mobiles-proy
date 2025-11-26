import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:harmonymusic/domain/library/repository/library_repository.dart';
import 'package:harmonymusic/domain/library/usecases/get_library_albums_usecase.dart';
import 'package:harmonymusic/domain/library/entities/library_album_entity.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';

import 'get_library_songs_usecase_test.mocks.dart';

@GenerateMocks([LibraryRepository])
void main() {
  late MockLibraryRepository mockRepository;
  late GetLibraryAlbumsUseCase useCase;

  setUp(() {
    mockRepository = MockLibraryRepository();
    Get.put<LibraryRepository>(mockRepository);
    useCase = GetLibraryAlbumsUseCase();
  });

  tearDown(() {
    Get.reset();
  });

  group('GetLibraryAlbumsUseCase', () {
    final testAlbums = [
      LibraryAlbumEntity(
        id: 'album1',
        title: 'Album 1',
        addedAt: DateTime.now(),
        artist: 'Artist 1',
        thumbnailUrl: 'url1',
      ),
      LibraryAlbumEntity(
        id: 'album2',
        title: 'Album 2',
        addedAt: DateTime.now(),
        artist: 'Artist 2',
        thumbnailUrl: 'url2',
      ),
    ];

    test('should return list of albums from repository', () async {
      // Arrange
      when(mockRepository.getLibraryAlbums())
          .thenAnswer((_) async => testAlbums);

      // Act
      final result = await useCase();

      // Assert
      expect(result, testAlbums);
      expect(result.length, 2);
      verify(mockRepository.getLibraryAlbums()).called(1);
    });

    test('should return empty list when no albums', () async {
      // Arrange
      when(mockRepository.getLibraryAlbums()).thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getLibraryAlbums()).called(1);
    });

    test('should propagate exception from repository', () async {
      // Arrange
      when(mockRepository.getLibraryAlbums())
          .thenThrow(LibraryException('Failed to get albums'));

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(isA<LibraryException>()),
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:harmonymusic/domain/library/repository/library_repository.dart';
import 'package:harmonymusic/domain/library/usecases/get_library_artists_usecase.dart';
import 'package:harmonymusic/domain/library/entities/library_artist_entity.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';

import 'get_library_songs_usecase_test.mocks.dart';

@GenerateMocks([LibraryRepository])
void main() {
  late MockLibraryRepository mockRepository;
  late GetLibraryArtistsUseCase useCase;

  setUp(() {
    mockRepository = MockLibraryRepository();
    Get.put<LibraryRepository>(mockRepository);
    useCase = GetLibraryArtistsUseCase();
  });

  tearDown(() {
    Get.reset();
  });

  group('GetLibraryArtistsUseCase', () {
    final testArtists = [
      LibraryArtistEntity(
        id: 'artist1',
        title: 'Artist 1',
        addedAt: DateTime.now(),
        thumbnailUrl: 'url1',
      ),
      LibraryArtistEntity(
        id: 'artist2',
        title: 'Artist 2',
        addedAt: DateTime.now(),
        thumbnailUrl: 'url2',
      ),
    ];

    test('should return list of artists from repository', () async {
      // Arrange
      when(mockRepository.getLibraryArtists())
          .thenAnswer((_) async => testArtists);

      // Act
      final result = await useCase();

      // Assert
      expect(result, testArtists);
      expect(result.length, 2);
      verify(mockRepository.getLibraryArtists()).called(1);
    });

    test('should return empty list when no artists', () async {
      // Arrange
      when(mockRepository.getLibraryArtists()).thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getLibraryArtists()).called(1);
    });

    test('should propagate exception from repository', () async {
      // Arrange
      when(mockRepository.getLibraryArtists())
          .thenThrow(LibraryException('Failed to get artists'));

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(isA<LibraryException>()),
      );
    });
  });
}

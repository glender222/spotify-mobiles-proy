import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:harmonymusic/domain/library/repository/library_repository.dart';
import 'package:harmonymusic/domain/library/usecases/get_library_songs_usecase.dart';
import 'package:harmonymusic/domain/library/entities/library_song_entity.dart';
import 'package:get/get.dart';

@GenerateMocks([LibraryRepository])
import 'get_library_songs_usecase_test.mocks.dart';

void main() {
  late MockLibraryRepository mockRepository;
  late GetLibrarySongsUseCase useCase;

  setUp(() {
    mockRepository = MockLibraryRepository();
    // Register mock repository with GetX
    Get.put<LibraryRepository>(mockRepository);
    useCase = GetLibrarySongsUseCase();
  });

  tearDown(() {
    Get.reset();
  });

  group('GetLibrarySongsUseCase', () {
    final testSongs = [
      LibrarySongEntity(
        id: 'song1',
        title: 'Song 1',
        addedAt: DateTime.now(),
        artist: 'Artist 1',
        thumbnailUrl: 'url1',
      ),
      LibrarySongEntity(
        id: 'song2',
        title: 'Song 2',
        addedAt: DateTime.now(),
        artist: 'Artist 2',
        thumbnailUrl: 'url2',
      ),
    ];

    test('should return list of songs from repository', () async {
      // Arrange
      when(mockRepository.getLibrarySongs()).thenAnswer((_) async => testSongs);

      // Act
      final result = await useCase();

      // Assert
      expect(result, testSongs);
      expect(result.length, 2);
      verify(mockRepository.getLibrarySongs()).called(1);
    });

    test('should return empty list when no songs', () async {
      // Arrange
      when(mockRepository.getLibrarySongs()).thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getLibrarySongs()).called(1);
    });

    test('should propagate exception from repository', () async {
      // Arrange
      when(mockRepository.getLibrarySongs())
          .thenThrow(LibraryException('Failed to get songs'));

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(isA<LibraryException>()),
      );
      verify(mockRepository.getLibrarySongs()).called(1);
    });
  });
}

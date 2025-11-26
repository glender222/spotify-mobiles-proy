import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:harmonymusic/domain/library/repository/library_repository.dart';
import 'package:harmonymusic/domain/library/usecases/remove_song_from_library_usecase.dart';
import 'package:get/get.dart';

import 'get_library_songs_usecase_test.mocks.dart';

@GenerateMocks([LibraryRepository])
void main() {
  late MockLibraryRepository mockRepository;
  late RemoveSongFromLibraryUseCase useCase;

  setUp(() {
    mockRepository = MockLibraryRepository();
    Get.put<LibraryRepository>(mockRepository);
    useCase = RemoveSongFromLibraryUseCase();
  });

  tearDown(() {
    Get.reset();
  });

  group('RemoveSongFromLibraryUseCase', () {
    const testSongId = 'song123';

    test('should remove song without deleting file', () async {
      // Arrange
      when(mockRepository.removeSongFromLibrary(any, deleteFile: false))
          .thenAnswer((_) async => {});

      // Act
      await useCase(testSongId, deleteFile: false);

      // Assert
      verify(mockRepository.removeSongFromLibrary(testSongId,
              deleteFile: false))
          .called(1);
    });

    test('should remove song and delete file when requested', () async {
      // Arrange
      when(mockRepository.removeSongFromLibrary(any, deleteFile: true))
          .thenAnswer((_) async => {});

      // Act
      await useCase(testSongId, deleteFile: true);

      // Assert
      verify(mockRepository.removeSongFromLibrary(testSongId, deleteFile: true))
          .called(1);
    });

    test('should propagate exception from repository', () async {
      // Arrange
      when(mockRepository.removeSongFromLibrary(any,
              deleteFile: anyNamed('deleteFile')))
          .thenThrow(LibraryException('Failed to remove song'));

      // Act & Assert
      expect(
        () => useCase(testSongId),
        throwsA(isA<LibraryException>()),
      );
    });
  });
}

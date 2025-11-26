import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../base_class/playlist_album_screen_con_base.dart';
import '../../../domain/album/entities/album_entity.dart';
import '../../../domain/album/usecases/get_album_details_usecase.dart';
import '../../../domain/album/usecases/get_album_tracks_usecase.dart';
import '../../../domain/album/usecases/add_album_to_library_usecase.dart';
import '../../../domain/album/usecases/remove_album_from_library_usecase.dart';
import '../../../domain/album/usecases/is_album_in_library_usecase.dart';
import '../../../mixins/additional_opeartion_mixin.dart';
import '../../../models/album.dart'; // Legacy model for compatibility
import '../../../models/playlist.dart';
import '../../../utils/helper.dart';
import '../home/home_controller.dart';
import '../library/library_albums_controller.dart';

/// AlbumController - Hybrid Clean Architecture Approach
///
/// ✅ Extends base class for UI operations (scroll, search, animations)
/// ✅ Uses UseCases for domain/business logic (fetch, library management)
///
/// This provides Clean Architecture where it matters (business logic)
/// while reusing proven UI code from base class and mixin.
class AlbumController extends PlaylistAlbumScreenControllerBase
    with AdditionalOpeartionMixin, GetSingleTickerProviderStateMixin {
  // ✅ CLEAN ARCHITECTURE: Injected UseCases for domain logic
  final GetAlbumDetailsUseCase _getAlbumDetails;
  final GetAlbumTracksUseCase _getAlbumTracks;
  final AddAlbumToLibraryUseCase _addToLibrary;
  final RemoveAlbumFromLibraryUseCase _removeFromLibrary;
  final IsAlbumInLibraryUseCase _isInLibrary;

  AlbumController({
    required GetAlbumDetailsUseCase getAlbumDetails,
    required GetAlbumTracksUseCase getAlbumTracks,
    required AddAlbumToLibraryUseCase addToLibrary,
    required RemoveAlbumFromLibraryUseCase removeFromLibrary,
    required IsAlbumInLibraryUseCase isInLibrary,
  })  : _getAlbumDetails = getAlbumDetails,
        _getAlbumTracks = getAlbumTracks,
        _addToLibrary = addToLibrary,
        _removeFromLibrary = removeFromLibrary,
        _isInLibrary = isInLibrary;

  // State - Using AlbumEntity (domain) but mapped to Album (legacy) for UI compatibility
  final album =
      Album(title: "", browseId: "", thumbnailUrl: "", artists: []).obs;
  final albumEntity = Rxn<AlbumEntity>(); // Domain entity

  // Title animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _heightAnimation;

  AnimationController get animationController => _animationController;
  Animation<double> get scaleAnimation => _scaleAnimation;
  Animation<double> get heightAnimation => _heightAnimation;

  @override
  void onInit() {
    super.onInit();
    _initAnimation();

    final args = Get.arguments as (Album?, String);
    fetchAlbumDetails(args.$1, args.$2);

    Future.delayed(const Duration(milliseconds: 200),
        () => Get.find<HomeController>().whenHomeScreenOnTop());
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation =
        Tween<double>(begin: 0, end: 1.0).animate(animationController);
    _heightAnimation = Tween<double>(begin: 10.0, end: 90.0).animate(
        CurvedAnimation(
            parent: animationController, curve: Curves.easeOutBack));
  }

  /// ✅ CLEAN ARCHITECTURE: Uses UseCases for fetching album data
  @override
  void fetchAlbumDetails(Album? album_, String albumId) async {
    try {
      if (album_ != null) {
        album.value = album_;
        animationController.forward();
      }

      // ✅ UseCase: Check if in library
      final inLibrary = await _isInLibrary(albumId);
      isAddedToLibrary.value = inLibrary;

      if (!inLibrary) {
        // ✅ UseCase: Fetch from API
        albumEntity.value = await _getAlbumDetails(albumId);
        songList.value = await _getAlbumTracks(albumId);

        // Map entity to legacy model for UI compatibility
        album.value = _entityToLegacyModel(albumEntity.value!, albumId);
      } else {
        // ✅ UseCase: Get from local library
        albumEntity.value =
            await _getAlbumDetails(albumId); // Repository will get from local
        songList.value = await _getAlbumTracks(albumId);

        album.value = _entityToLegacyModel(albumEntity.value!, albumId);
      }

      animationController.forward();
      checkDownloadStatus();
      isContentFetched.value = true;
    } catch (e) {
      printERROR("Error fetching album details: $e");
      isContentFetched.value = true;
    }
  }

  /// ✅ CLEAN ARCHITECTURE: Uses UseCases for library operations
  @override
  Future<bool> addNremoveFromLibrary(content, {bool add = true}) async {
    try {
      if (albumEntity.value == null) return false;

      if (add) {
        // ✅ UseCase: Add to library
        final success = await _addToLibrary(albumEntity.value!, songList);
        if (success) {
          isAddedToLibrary.value = true;
          Get.find<LibraryAlbumsController>().refreshLib();
        }
        return success;
      } else {
        // ✅ UseCase: Remove from library
        final success = await _removeFromLibrary(albumEntity.value!.id);
        if (success) {
          isAddedToLibrary.value = false;
          Get.find<LibraryAlbumsController>().refreshLib();
        }
        return success;
      }
    } catch (e) {
      printERROR("Error adding/removing from library: $e");
      return false;
    }
  }

  /// Maps AlbumEntity (domain) to Album (legacy model) for UI compatibility
  Album _entityToLegacyModel(AlbumEntity entity, String albumId) {
    return Album(
      title: entity.title,
      browseId: albumId,
      thumbnailUrl: entity.thumbnailUrl ?? "",
      artists: entity.artists
          .map((artist) => {
                'name': artist.name,
                'id': artist.id,
              })
          .toList(),
      year: entity.year,
      description: entity.description,
      audioPlaylistId: entity.audioPlaylistId,
    );
  }

  @override
  Future<bool> checkIfAddedToLibrary(String id) async {
    try {
      // ✅ UseCase: Check library status
      isAddedToLibrary.value = await _isInLibrary(id);
      return isAddedToLibrary.value;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateSongsIntoDb() async {
    // Songs are automatically saved when adding to library via UseCase
    // This method is kept for compatibility with base class
  }

  @override
  void onClose() {
    tempListContainer.clear();
    _animationController.dispose();
    Get.find<HomeController>().whenHomeScreenOnTop();
    super.onClose();
  }

  @override
  Future<void> deleteMultipleSongs(List<MediaItem> songs) async {
    // Not applicable for albums
  }

  @override
  void fetchPlaylistDetails(Playlist? playlist_, String playlistId) {
    // Not applicable for albums
  }

  @override
  void syncPlaylistSongs() {
    // Not applicable for albums
  }
}

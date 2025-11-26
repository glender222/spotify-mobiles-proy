/// Base entity for all library items
abstract class LibraryItemEntity {
  final String id;
  final String title;
  final DateTime addedAt;
  final LibraryItemType itemType;

  LibraryItemEntity({
    required this.id,
    required this.title,
    required this.addedAt,
    required this.itemType,
  });

  Map<String, dynamic> toJson();
}

/// Types of items that can be stored in library
enum LibraryItemType {
  song,
  album,
  artist,
  playlist,
}

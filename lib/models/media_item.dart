// Media Item
class MediaItem {
  final String id;
  final String collectionTypeId;
  final String title;
  final String creator;   // artist / author / director
  final int year;
  // Optional fields
  final String? genre;
  final String? imagePath; // local path or network URL
  final String? barcode;
  final DateTime addedAt;
  final Map<String, String> customFields; // for user-defined extra fields

  const MediaItem({
    required this.id,
    required this.collectionTypeId,
    required this.title,
    required this.creator,
    required this.year,
    this.genre,
    this.imagePath,
    this.barcode,
    required this.addedAt,
    this.customFields = const {},
  });
}



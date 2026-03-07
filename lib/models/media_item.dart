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

  // Sample data for UI prototyping
  static final List<MediaItem> samples = [
    MediaItem(
      id: '1',
      collectionTypeId: 'cds',
      title: 'Abbey Road',
      creator: 'The Beatles',
      year: 1969,
      genre: 'Rock',
      imagePath: 'https://upload.wikimedia.org/wikipedia/en/4/42/Beatles_-_Abbey_Road.jpg',
      addedAt: DateTime(2026, 1, 10),
    ),
    MediaItem(
      id: '2',
      collectionTypeId: 'books',
      title: '1984',
      creator: 'George Orwell',
      year: 1949,
      genre: 'Fiction',
      addedAt: DateTime(2025, 2, 5),
    ),
    MediaItem(
      id: '3',
      collectionTypeId: 'dvds',
      title: 'Pulp Fiction',
      creator: 'Quentin Tarantino',
      year: 1994,
      genre: 'Thriller',
      addedAt: DateTime(2024, 2, 20),
    ),
    MediaItem(
      id: '4',
      collectionTypeId: 'cds',
      title: 'Nevermind',
      creator: 'Nirvana',
      year: 1991,
      genre: 'Rock',
      addedAt: DateTime(2025, 3, 1),
    ),
    MediaItem(
      id: '5',
      collectionTypeId: 'books',
      title: 'Dune',
      creator: 'Frank Herbert',
      year: 1965,
      genre: 'Sci-Fi',
      addedAt: DateTime(2026, 3, 15),
    ),
    MediaItem(
      id: '6',
      collectionTypeId: 'vinyl',
      title: 'Kind of Blue',
      creator: 'Miles Davis',
      year: 1959,
      genre: 'Jazz',
      addedAt: DateTime(2024, 4, 2),
    ),
    MediaItem(
      id: '7',
      collectionTypeId: 'dvds',
      title: 'The Godfather',
      creator: 'Francis Ford Coppola',
      year: 1972,
      genre: 'Drama',
      addedAt: DateTime(2025, 4, 18),
    ),
    MediaItem(
      id: '8',
      collectionTypeId: 'books',
      title: 'The Great Gatsby',
      creator: 'F. Scott Fitzgerald',
      year: 1925,
      genre: 'Fiction',
      addedAt: DateTime(2024, 5, 1),
    ),
  ];
}



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/media_item.dart';
import '../models/collection_type.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._internal();
  factory FirestoreService() => instance;
  FirestoreService._internal();

  final _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'default',
  );

  // Helper to get the current user's document reference
  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _itemsRef =>
      _db.collection('users').doc(_userId).collection('items');

  CollectionReference get _typesRef =>
      _db.collection('users').doc(_userId).collection('collection_types');

  // Collection Types

  Future<void> saveCollectionType(CollectionType type) async {
    await _typesRef.doc(type.id).set({
      'id': type.id,
      'name': type.name,
      'icon_name': type.iconName,
      'is_custom': type.isCustom,
    });
  }

  Future<void> deleteCollectionType(String id) async {
    await _typesRef.doc(id).delete();
  }

  Future<List<CollectionType>> getCollectionTypes() async {
    final snapshot = await _typesRef.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return CollectionType(
        id: data['id'] as String,
        name: data['name'] as String,
        iconName: data['icon_name'] as String,
        isCustom: data['is_custom'] as bool,
      );
    }).toList();
  }

  // Media Items

  Future<void> saveItem(MediaItem item) async {
    await _itemsRef.doc(item.id).set({
      'id': item.id,
      'collection_type_id': item.collectionTypeId,
      'title': item.title,
      'creator': item.creator,
      'year': item.year,
      'genre': item.genre,
      'image_path': item.imagePath,
      'barcode': item.barcode,
      'added_at': item.addedAt.toIso8601String(),
    });
  }

  Future<void> deleteItem(String id) async {
    await _itemsRef.doc(id).delete();
  }

  Future<List<MediaItem>> getItems() async {
    final snapshot = await _itemsRef.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return MediaItem(
        id: data['id'] as String,
        collectionTypeId: data['collection_type_id'] as String,
        title: data['title'] as String,
        creator: data['creator'] as String,
        year: data['year'] as int,
        genre: data['genre'] as String?,
        imagePath: data['image_path'] as String?,
        barcode: data['barcode'] as String?,
        addedAt: DateTime.parse(data['added_at'] as String),
      );
    }).toList();
  }

  // Sync

  // Pull everything from Firestore and return it
  // Used on first login to seed local SQLite
  Future<({List<CollectionType> types, List<MediaItem> items})> fetchAll() async {
    final types = await getCollectionTypes();
    final items = await getItems();
    return (types: types, items: items);
  }
}
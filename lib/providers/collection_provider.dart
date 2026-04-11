import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../models/collection_type.dart';
import '../services/database_service.dart';
import '../services/firestore_service.dart';

class CollectionProvider extends ChangeNotifier {

  // State
  List<CollectionType> _collectionTypes = [];
  List<MediaItem> _items = [];
  bool _isLoading = false;

  // Getters
  List<CollectionType> get collectionTypes => _collectionTypes;
  List<MediaItem> get items => _items;
  bool get isLoading => _isLoading;

  // Init
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    // Always sync from Firestore on login to ensure correct user data
    await _syncFromFirestore();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _syncFromFirestore() async {
    try {
      final data = await FirestoreService.instance.fetchAll();

      if (data.types.isNotEmpty) {
        await DatabaseService.instance.clearLocalData();
        for (final type in data.types) {
          await DatabaseService.instance.insertCollectionType(type);
        }
        for (final item in data.items) {
          await DatabaseService.instance.insertItem(item);
        }
        _collectionTypes = data.types;
        _items = data.items;
      } else {
        // Check if this is truly a new user or just a slow connection
        // Wait briefly and retry once
        await Future.delayed(const Duration(seconds: 2));
        final retryData = await FirestoreService.instance.fetchAll();

        if (retryData.types.isNotEmpty) {
          await DatabaseService.instance.clearLocalData();
          for (final type in retryData.types) {
            await DatabaseService.instance.insertCollectionType(type);
          }
          for (final item in retryData.items) {
            await DatabaseService.instance.insertItem(item);
          }
          _collectionTypes = retryData.types;
          _items = retryData.items;
        } else {
          // Truly a new user
          for (final type in CollectionType.defaults) {
            await DatabaseService.instance.insertCollectionType(type);
            await FirestoreService.instance.saveCollectionType(type);
          }
          _collectionTypes = List.from(CollectionType.defaults);
          _items = [];
        }
      }
    } catch (e) {
      print('Firestore sync error: $e');
      for (final type in CollectionType.defaults) {
        await DatabaseService.instance.insertCollectionType(type);
      }
      _collectionTypes = List.from(CollectionType.defaults);
      _items = [];
    }
  }

  // Items
  Future<void> addItem(MediaItem item) async {
    await DatabaseService.instance.insertItem(item);
    await FirestoreService.instance.saveItem(item);
    _items.add(item);
    notifyListeners();
  }

  Future<void> updateItem(MediaItem updated) async {
    await DatabaseService.instance.updateItem(updated);
    await FirestoreService.instance.saveItem(updated);
    final index = _items.indexWhere((item) => item.id == updated.id);
    if (index != -1) {
      _items[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    await DatabaseService.instance.deleteItem(id);
    await FirestoreService.instance.deleteItem(id);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Collection Types
  Future<void> addCollectionType(CollectionType type) async {
    await DatabaseService.instance.insertCollectionType(type);
    await FirestoreService.instance.saveCollectionType(type);
    _collectionTypes.add(type);
    notifyListeners();
  }

  Future<void> updateCollectionType(CollectionType updated) async {
    await DatabaseService.instance.updateCollectionType(updated);
    await FirestoreService.instance.saveCollectionType(updated);
    final index = _collectionTypes.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _collectionTypes[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteCollectionType(String id) async {
    await DatabaseService.instance.deleteCollectionType(id);
    await FirestoreService.instance.deleteCollectionType(id);
    _collectionTypes.removeWhere((type) => type.id == id);
    _items.removeWhere((item) => item.collectionTypeId == id);
    notifyListeners();
  }

  // Stats
  int get totalItems => _items.length;

  Map<String, int> get countByType {
    final map = <String, int>{};
    for (final item in _items) {
      map[item.collectionTypeId] = (map[item.collectionTypeId] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get topGenres {
    final map = <String, int>{};
    for (final item in _items) {
      if (item.genre != null) {
        map[item.genre!] = (map[item.genre!] ?? 0) + 1;
      }
    }
    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  Map<String, int> get countByDecade {
    final map = <String, int>{};
    for (final item in _items) {
      final decade = '${(item.year ~/ 10) * 10}s';
      map[decade] = (map[decade] ?? 0) + 1;
    }
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return Map.fromEntries(sorted);
  }

  List<MediaItem> get recentItems {
    final sorted = List<MediaItem>.from(_items)
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return sorted.take(5).toList();
  }

  List<MediaItem> filteredItems(Set<String> typeIds) {
    if (typeIds.isEmpty) return _items;
    return _items.where((item) => typeIds.contains(item.collectionTypeId)).toList();
  }

  Map<String, int> filteredCountByType(Set<String> typeIds) {
    final source = filteredItems(typeIds);
    final map = <String, int>{};
    for (final item in source) {
      map[item.collectionTypeId] = (map[item.collectionTypeId] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> filteredTopGenres(Set<String> typeIds) {
    final source = filteredItems(typeIds);
    final map = <String, int>{};
    for (final item in source) {
      if (item.genre != null) {
        map[item.genre!] = (map[item.genre!] ?? 0) + 1;
      }
    }
    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  Map<String, int> filteredCountByDecade(Set<String> typeIds) {
    final source = filteredItems(typeIds);
    final map = <String, int>{};
    for (final item in source) {
      final decade = '${(item.year ~/ 10) * 10}s';
      map[decade] = (map[decade] ?? 0) + 1;
    }
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return Map.fromEntries(sorted);
  }

  List<MediaItem> filteredRecentItems(Set<String> typeIds) {
    final source = filteredItems(typeIds);
    final sorted = List<MediaItem>.from(source)
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return sorted.take(5).toList();
  }

  Future<void> clearData() async {
    await DatabaseService.instance.clearLocalData();
    _items = [];
    _collectionTypes = [];
    notifyListeners();
  }
}
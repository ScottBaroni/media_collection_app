import 'package:flutter/material.dart';
import '../../models/media_item.dart';
import '../../models/collection_type.dart';
import '../../services/database_service.dart';

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
    print('--- loadData called ---');
    _isLoading = true;
    notifyListeners();

    _collectionTypes = await DatabaseService.instance.getCollectionTypes();
    print('--- got ${_collectionTypes.length} types ---');
    _items = await DatabaseService.instance.getItems();
    print('--- got ${_items.length} items ---');

    _isLoading = false;
    print('--- isLoading set to false ---');
    notifyListeners();
    print('--- notifyListeners called ---');
  }

  // Items
  Future<void> addItem(MediaItem item) async {
    await DatabaseService.instance.insertItem(item);  // Save to database
    _items.add(item);                                 // Update in memory
    notifyListeners();                                // Notify UI
  }

  Future<void> updateItem(MediaItem updated) async {
    await DatabaseService.instance.updateItem(updated);
    final index = _items.indexWhere((item) => item.id == updated.id);
    if (index != -1) {
      _items[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    await DatabaseService.instance.deleteItem(id);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Collection Types
  Future<void> addCollectionType(CollectionType type) async {
    await DatabaseService.instance.insertCollectionType(type);
    _collectionTypes.add(type);
    notifyListeners();
  }

  Future<void> deleteCollectionType(String id) async {
    await DatabaseService.instance.deleteCollectionType(id);
    _collectionTypes.removeWhere((type) => type.id == id);
    _items.removeWhere((item) => item.collectionTypeId == id);
    notifyListeners();
  }

  // Stats

  int get totalItems => _items.length;

  // Collection Type Stat
  Map<String, int> get countByType {
    final map = <String, int>{};
    for (final item in _items) {
      map[item.collectionTypeId] = (map[item.collectionTypeId] ?? 0) + 1;
    }
    return map;
  }
  // Top Genre Stat
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
  // Top Decade Stat
  Map<String, int> get countByDecade {
    final map = <String, int>{};
    for (final item in _items) {
      final decade = '${(item.year ~/ 10) * 10}s';
      map[decade] = (map[decade] ?? 0) + 1;
    }
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return Map.fromEntries(sorted);
  }
  // Recently Added Items
  List<MediaItem> get recentItems {
    final sorted = List<MediaItem>.from(_items)
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return sorted.take(5).toList();
  }

  // Filtering Stats
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
}
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
    _isLoading = true;
    notifyListeners();

    _collectionTypes = await DatabaseService.instance.getCollectionTypes();
    _items = await DatabaseService.instance.getItems();

    _isLoading = false;
    notifyListeners();
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
}
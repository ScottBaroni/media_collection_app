import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../models/collection_type.dart';

class CollectionProvider extends ChangeNotifier {

  // State
  List<CollectionType> _collectionTypes = List.from(CollectionType.defaults);
  List<MediaItem> _items = [];

  // Getters
  List<CollectionType> get collectionTypes => _collectionTypes;
  List<MediaItem> get items => _items;

}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/collection_provider.dart';
import '../models/media_item.dart';
import '../models/collection_type.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  String? _selectedTypeId; // null means "All"

  List<MediaItem> _filteredItems(List<MediaItem> items) {
    if (_selectedTypeId == null) return items;
    return items.where((item) => item.collectionTypeId == _selectedTypeId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();
    final filtered = _filteredItems(provider.items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {}, // TODO: search
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Filter Chips
          _FilterBar(
            collectionTypes: provider.collectionTypes,
            selectedTypeId: _selectedTypeId,
            onSelected: (id) => setState(() => _selectedTypeId = id),
          ),

          // Grid
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyState()
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final type = provider.collectionTypes.firstWhere(
                      (t) => t.id == item.collectionTypeId,
                  orElse: () => CollectionType(id: '', name: 'Unknown', iconName: '🗂️'),
                );
                return _MediaCard(item: item, typeName: type.name, typeEmoji: type.emoji);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddItemScreen()),
        ),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// Filter Bar

class _FilterBar extends StatelessWidget {
  final List<CollectionType> collectionTypes;
  final String? selectedTypeId;
  final ValueChanged<String?> onSelected;

  const _FilterBar({
    required this.collectionTypes,
    required this.selectedTypeId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // "All" chip
          _Chip(
            label: 'All',
            isSelected: selectedTypeId == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          // One chip per collection type
          ...collectionTypes.map((type) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _Chip(
              label: type.name,
              isSelected: selectedTypeId == type.id,
              onTap: () => onSelected(type.id),
            ),
          )),
        ],
      ),
    );
  }
}

// Chip

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}

// Media Card

class _MediaCard extends StatelessWidget {
  final MediaItem item;
  final String typeName;
  final String typeEmoji;
  const _MediaCard({required this.item, required this.typeName, required this.typeEmoji});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemDetailScreen(itemId: item.id)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Art
            Expanded(
              child: item.imagePath != null
                ? Image.file(
                  File(item.imagePath!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                  : _PlaceholderArt(emoji: typeEmoji),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    item.creator,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    item.year.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder Art

class _PlaceholderArt extends StatelessWidget {
  final String emoji; // changed from collectionTypeId
  const _PlaceholderArt({required this.emoji}); // changed

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 48)),
      ),
    );
  }
}

// Empty State

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📦', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Nothing here yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first item',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
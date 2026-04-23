import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/collection_provider.dart';
import '../models/media_item.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ItemDetailScreen extends StatefulWidget {
  final String itemId; // changed from MediaItem item

  const ItemDetailScreen({super.key, required this.itemId}); // changed from required this.item

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  String? _editedImagePath;

  late final TextEditingController _titleController;
  late final TextEditingController _creatorController;
  late final TextEditingController _yearController;
  late final TextEditingController _genreController;
  late String? _selectedTypeId;

  // Helper to get the original item from the provider for initState/cancelEdit
  MediaItem _originalItem(BuildContext context) =>
      context.read<CollectionProvider>().items.firstWhere((i) => i.id == widget.itemId);

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback so context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final item = _originalItem(context);
      _titleController.text = item.title;
      _creatorController.text = item.creator;
      _yearController.text = item.year.toString();
      _genreController.text = item.genre ?? '';
      setState(() => _selectedTypeId = item.collectionTypeId);
    });
    _titleController = TextEditingController();
    _creatorController = TextEditingController();
    _yearController = TextEditingController();
    _genreController = TextEditingController();
    _selectedTypeId = null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _creatorController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final original = _originalItem(context);
    final updated = MediaItem(
      id: widget.itemId,
      collectionTypeId: _selectedTypeId!,
      title: _titleController.text.trim(),
      creator: _creatorController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      genre: _genreController.text.trim().isEmpty
          ? null
          : _genreController.text.trim(),
      imagePath: _editedImagePath == null
          ? original.imagePath
          : _editedImagePath!.isEmpty ? null : _editedImagePath,
      barcode: original.barcode,
      addedAt: original.addedAt,
    );

    await context.read<CollectionProvider>().updateItem(updated);

    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final original = _originalItem(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${original.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<CollectionProvider>().deleteItem(widget.itemId);
      if (mounted) Navigator.pop(context);
    }
  }

  void _cancelEdit() {
    final original = _originalItem(context);
    _titleController.text = original.title;
    _creatorController.text = original.creator;
    _yearController.text = original.year.toString();
    _genreController.text = original.genre ?? '';
    setState(() {
      _selectedTypeId = original.collectionTypeId;
      _editedImagePath = null; // reset image
      _isEditing = false;
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                final image = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (image != null) setState(() => _editedImagePath = image.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                final image = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null) setState(() => _editedImagePath = image.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.hide_image_outlined),
              title: const Text('Remove image'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _editedImagePath = '');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverArt(MediaItem item) {
    // In edit mode, show the edited image if one was picked
    final pathToShow = _editedImagePath == null
        ? item.imagePath
        : _editedImagePath!.isEmpty ? null : _editedImagePath;

    if (pathToShow != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(pathToShow), fit: BoxFit.cover),
          if (_isEditing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Icon(Icons.edit, color: Colors.white, size: 32),
              ),
            ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _isEditing ? Icons.add_photo_alternate_rounded : Icons.image_not_supported_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        Text(
          _isEditing ? 'Add Cover Art' : 'No Image',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();

    // Always read fresh from provider
    final item = provider.items.firstWhere((i) => i.id == widget.itemId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'Item Detail'),
        actions: [
          if (_isEditing) ...[
            TextButton(
              onPressed: _cancelEdit,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Save'),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.red,
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // Cover Art
            GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.hardEdge,
                child: _buildCoverArt(item),
              ),
            ),
            const SizedBox(height: 24),

            // Collection Type
            _isEditing
                ? DropdownButtonFormField<String>(
              value: _selectedTypeId,
              decoration: _inputDecoration('Collection Type'),
              items: provider.collectionTypes
                  .map((type) => DropdownMenuItem(
                value: type.id,
                child: Text(type.name),
              ))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedTypeId = value),
              validator: (value) =>
              value == null ? 'Please select a type' : null,
            )
                : _InfoRow(
              label: 'Type',
              value: provider.collectionTypes
                  .firstWhere(
                    (t) => t.id == item.collectionTypeId,
                orElse: () => provider.collectionTypes.first,
              )
                  .name,
            ),
            const SizedBox(height: 16),

            // Title
            _isEditing
                ? TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('Title'),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
              value == null || value.trim().isEmpty
                  ? 'Title is required'
                  : null,
            )
                : _InfoRow(label: 'Title', value: item.title),
            const SizedBox(height: 16),

            // Creator
            _isEditing
                ? TextFormField(
              controller: _creatorController,
              decoration: _inputDecoration('Artist / Author / Director'),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
              value == null || value.trim().isEmpty
                  ? 'Creator is required'
                  : null,
            )
                : _InfoRow(label: 'Creator', value: item.creator),
            const SizedBox(height: 16),

            // Year
            _isEditing
                ? TextFormField(
              controller: _yearController,
              decoration: _inputDecoration('Year'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty)
                  return 'Year is required';
                final year = int.tryParse(value.trim());
                if (year == null) return 'Enter a valid year';
                if (year < 1000 || year > DateTime.now().year)
                  return 'Enter a realistic year';
                return null;
              },
            )
                : _InfoRow(label: 'Year', value: item.year.toString()),
            const SizedBox(height: 16),

            // Genre
            _isEditing
                ? TextFormField(
              controller: _genreController,
              decoration: _inputDecoration('Genre (optional)'),
              textCapitalization: TextCapitalization.words,
            )
                : _InfoRow(
              label: 'Genre',
              value: item.genre ?? 'Not set',
            ),
            const SizedBox(height: 16),

            // Added date (view only, never editable)
            _InfoRow(
              label: 'Added',
              value: '${item.addedAt.month}/${item.addedAt.day}/${item.addedAt.year}',
            ),
          ],
        ),
      ),
    );
  }

  String _emoji(String collectionTypeId) {
    switch (collectionTypeId) {
      case 'cds': return '💿';
      case 'dvds': return '📀';
      case 'books': return '📖';
      default: return '🗂️';
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    );
  }
}

// Info Row (view mode)

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/collection_provider.dart';
import '../models/media_item.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _creatorController = TextEditingController();
  final _yearController = TextEditingController();
  final _genreController = TextEditingController();
  String? _selectedTypeId;
  bool _isSaving = false;

  @override
  void dispose() {
    // Dispose controllers when the screen is removed
    _titleController.dispose();
    _creatorController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Validate form - if any validator returns an error, stop here
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final item = MediaItem(
      id: const Uuid().v4(),
      collectionTypeId: _selectedTypeId!,
      title: _titleController.text.trim(),
      creator: _creatorController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      genre: _genreController.text.trim().isEmpty ? null : _genreController.text.trim(),
      addedAt: DateTime.now(),
    );

    await context.read<CollectionProvider>().addItem(item);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // Collection Type
            DropdownButtonFormField<String>(
              value: _selectedTypeId,
              decoration: _inputDecoration('Collection Type'),
              items: provider.collectionTypes
                  .map((type) => DropdownMenuItem(
                value: type.id,
                child: Text(type.name),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedTypeId = value),
              validator: (value) => value == null ? 'Please select a type' : null,
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('Title'),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // Creator
            TextFormField(
              controller: _creatorController,
              decoration: _inputDecoration('Artist / Author / Director'),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Creator is required' : null,
            ),
            const SizedBox(height: 16),

            // Year
            TextFormField(
              controller: _yearController,
              decoration: _inputDecoration('Year'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Year is required';
                final year = int.tryParse(value.trim());
                if (year == null) return 'Enter a valid year';
                if (year < 1000 || year > DateTime.now().year) return 'Enter a realistic year';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Genre (optional)
            TextFormField(
              controller: _genreController,
              decoration: _inputDecoration('Genre (optional)'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text(
                'Add to Collection',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    );
  }
}
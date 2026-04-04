import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/collection_provider.dart';
import '../models/collection_type.dart';

class ManageCollectionsScreen extends StatelessWidget {
  const ManageCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Collections')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.collectionTypes.length,
        itemBuilder: (context, index) {
          final type = provider.collectionTypes[index];
          return _CollectionTypeItem(type: type);
        },
      ),
    );
  }
}

class _CollectionTypeItem extends StatelessWidget {
  final CollectionType type;
  const _CollectionTypeItem({required this.type});

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<CollectionProvider>();
    final itemCount = provider.items
        .where((item) => item.collectionTypeId == type.id)
        .length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection Type'),
        content: Text(
          itemCount > 0
              ? 'Are you sure you want to delete "${type.name}"? This will also delete $itemCount item${itemCount == 1 ? '' : 's'}.'
              : 'Are you sure you want to delete "${type.name}"?',
        ),
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

    if (confirmed == true && context.mounted) {
      await context.read<CollectionProvider>().deleteCollectionType(type.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(type.emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          type.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          type.isCustom ? 'Custom' : 'Default',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: type.isCustom
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditCollectionTypeScreen(type: type),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.red,
              onPressed: () => _confirmDelete(context),
            ),
          ],
        )
            : const Icon(Icons.lock_outline_rounded, size: 18), // defaults are locked
      ),
    );
  }
}

// Edit Collection Type Screen

class EditCollectionTypeScreen extends StatefulWidget {
  final CollectionType type;
  const EditCollectionTypeScreen({super.key, required this.type});

  @override
  State<EditCollectionTypeScreen> createState() =>
      _EditCollectionTypeScreenState();
}

class _EditCollectionTypeScreenState extends State<EditCollectionTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emojiController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.type.name);
    _emojiController = TextEditingController(text: widget.type.iconName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updated = CollectionType(
      id: widget.type.id,
      name: _nameController.text.trim(),
      iconName: _emojiController.text.trim(),
      isCustom: true,
    );

    await context.read<CollectionProvider>().updateCollectionType(updated);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Collection Type')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // Preview
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _emojiController.text.isEmpty
                          ? '🗂️'
                          : _emojiController.text,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nameController.text.isEmpty
                          ? 'Collection Name'
                          : _nameController.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _nameController.text.isEmpty
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Emoji field
            TextFormField(
              controller: _emojiController,
              decoration: _inputDecoration('Icon (paste an emoji)'),
              onChanged: (_) => setState(() {}),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Please add an icon' : null,
            ),
            const SizedBox(height: 16),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Collection Name'),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 32),

            // Save button
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
                'Save Changes',
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
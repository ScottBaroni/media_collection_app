import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/settings_provider.dart';
import '../providers/collection_provider.dart';
import 'create_collection_screen.dart';
import 'manage_collections_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final collection = context.watch<CollectionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // User Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  child: const Text('👤', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Collection',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${collection.totalItems} items',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Theme
          const Text(
            'Theme',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _ThemePicker(
            current: settings.theme,
            onChanged: (theme) => context.read<SettingsProvider>().setTheme(theme),
          ),
          const SizedBox(height: 24),

          // Collections
          const Text(
            'Collections',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.add_circle_outline_rounded,
                label: 'Create New Collection Type',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateCollectionScreen()),
                ),
              ),
              _SettingsItem(
                icon: Icons.edit_outlined,
                label: 'Manage Collection Types',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageCollectionsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Data
          const Text(
            'Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.upload_file_outlined,
                label: 'Import from Spreadsheet',
                onTap: () {}, // TODO
              ),
              _SettingsItem(
                icon: Icons.download_outlined,
                label: 'Export Collection',
                onTap: () {}, // TODO
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Account
          const Text(
            'Account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                onTap: () async {
                  await context.read<CollectionProvider>().clearData();
                  await FirebaseAuth.instance.signOut();
                },
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Theme Picker

class _ThemePicker extends StatelessWidget {
  final AppTheme current;
  final ValueChanged<AppTheme> onChanged;

  const _ThemePicker({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ThemeOption(
            label: 'Light',
            emoji: '☀️',
            isSelected: current == AppTheme.light,
            onTap: () => onChanged(AppTheme.light),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ThemeOption(
            label: 'Dark',
            emoji: '🌙',
            isSelected: current == AppTheme.dark,
            onTap: () => onChanged(AppTheme.dark),
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Settings Group

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(
                  item.icon,
                  color: item.isDestructive
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: item.isDestructive ? Colors.red : null,
                  ),
                ),
                trailing: item.isDestructive
                    ? null
                    : Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onTap: item.onTap,
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 56,
                  endIndent: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.15),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/collection_provider.dart';
import '../models/media_item.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Set<String> _selectedTypeIds = {};

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.totalItems == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stats')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('📊', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              Text(
                'No stats yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text('Add some items to see your stats'),
            ],
          ),
        ),
      );
    }

    // Compute filtered stats
    final filteredCount = _selectedTypeIds.isEmpty
        ? provider.totalItems
        : provider.filteredItems(_selectedTypeIds).length;
    final countByType = provider.filteredCountByType(_selectedTypeIds);
    final topGenres = provider.filteredTopGenres(_selectedTypeIds);
    final countByDecade = provider.filteredCountByDecade(_selectedTypeIds);
    final recentItems = provider.filteredRecentItems(_selectedTypeIds);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Filter Chips
          _FilterBar(
            collectionTypes: provider.collectionTypes,
            selectedTypeIds: _selectedTypeIds,
            onToggle: (id) {
              setState(() {
                if (_selectedTypeIds.contains(id)) {
                  _selectedTypeIds = Set.from(_selectedTypeIds)..remove(id);
                } else {
                  _selectedTypeIds = Set.from(_selectedTypeIds)..add(id);
                }
              });
            },
          ),
          const SizedBox(height: 20),

          // Overview
          _SectionHeader('Overview'),
          const SizedBox(height: 12),
          _OverviewCards(
            provider: provider,
            selectedTypeIds: _selectedTypeIds,
            filteredCount: filteredCount,
            countByType: countByType,
          ),
          const SizedBox(height: 24),

          // Top Genres
          _SectionHeader('Top Genres'),
          const SizedBox(height: 12),
          topGenres.isEmpty
              ? _EmptySection('No genre data for selection')
              : _BarChart(data: topGenres),
          const SizedBox(height: 24),

          // By Decade
          _SectionHeader('By Decade'),
          const SizedBox(height: 12),
          countByDecade.isEmpty
              ? _EmptySection('No decade data for selection')
              : _BarChart(data: countByDecade),
          const SizedBox(height: 24),

          // Recently Added
          _SectionHeader('Recently Added'),
          const SizedBox(height: 12),
          _RecentList(items: recentItems, provider: provider),
        ],
      ),
    );
  }
}

// Filter Bar

class _FilterBar extends StatelessWidget {
  final List<dynamic> collectionTypes;
  final Set<String> selectedTypeIds;
  final ValueChanged<String> onToggle;

  const _FilterBar({
    required this.collectionTypes,
    required this.selectedTypeIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: collectionTypes.map((type) {
          final isSelected = selectedTypeIds.contains(type.id);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onToggle(type.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  type.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Overview Cards

class _OverviewCards extends StatelessWidget {
  final CollectionProvider provider;
  final Set<String> selectedTypeIds;
  final int filteredCount;
  final Map<String, int> countByType;

  const _OverviewCards({
    required this.provider,
    required this.selectedTypeIds,
    required this.filteredCount,
    required this.countByType,
  });

  @override
  Widget build(BuildContext context) {
    // Which types to show cards for
    final typesToShow = selectedTypeIds.isEmpty
        ? provider.collectionTypes
        : provider.collectionTypes
        .where((t) => selectedTypeIds.contains(t.id))
        .toList();

    final cards = [
      (
      selectedTypeIds.isEmpty ? 'Total' : 'Selected Total',
      filteredCount,
      '🗂️'
      ),
      ...typesToShow.map((type) => (
      type.name,
      countByType[type.id] ?? 0,
      type.emoji,
      )),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: cards.map((card) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(card.$3, style: const TextStyle(fontSize: 24)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.$2.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    card.$1,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Section Header

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

// Bar Chart

class _BarChart extends StatelessWidget {
  final Map<String, int> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    final color = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: data.entries.map((entry) {
          final fraction = entry.value / maxValue;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    entry.key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: fraction,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  child: Text(
                    entry.value.toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Recent List

class _RecentList extends StatelessWidget {
  final List<MediaItem> items;
  final CollectionProvider provider;

  const _RecentList({required this.items, required this.provider});

  String _emoji(String collectionTypeId) {
    switch (collectionTypeId) {
      case 'cds': return '💿';
      case 'dvds': return '📀';
      case 'books': return '📖';
      default: return '🗂️';
    }
  }

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
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _emoji(item.collectionTypeId),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  item.creator,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Text(
                  '${item.addedAt.month}/${item.addedAt.day}/${item.addedAt.year}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 72,
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

// Empty Section

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
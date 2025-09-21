import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import '../models/declutter_item.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      backgroundColor: AppTheme.pureWhite,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final discardedItems = appState.discardedItems;

          if (discardedItems.isEmpty) {
            return Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.archive_outlined,
                        size: 64,
                        color: themeService.memoryIconBg,
                      ),
                  const SizedBox(height: 16),
                  Text(
                    'No memories yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Items you let go will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightGray,
                    ),
                  ),
                    ],
                  ),
                );
              },
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items Let Go',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${discardedItems.length} items',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _isGridView
                      ? _GridView(items: discardedItems)
                      : _ListView(items: discardedItems),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GridView extends StatelessWidget {
  final List<DeclutterItem> items;

  const _GridView({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _MemoryCard(item: item);
      },
    );
  }
}

class _ListView extends StatelessWidget {
  final List<DeclutterItem> items;

  const _ListView({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _MemoryCard(item: item, isList: true),
        );
      },
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final DeclutterItem item;
  final bool isList;

  const _MemoryCard({
    required this.item,
    this.isList = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGray),
        color: AppTheme.pureWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo placeholder
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: AppTheme.lightGray.withOpacity(0.3),
              child: item.photoPath != null
                  ? const Icon(
                      Icons.photo,
                      size: 32,
                      color: AppTheme.mediumGray,
                    )
                  : const Icon(
                      Icons.image_outlined,
                      size: 32,
                      color: AppTheme.lightGray,
                    ),
            ),
          ),
          // Content
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: isList ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.memo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.memo!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGray,
                      ),
                      maxLines: isList ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  Text(
                    _formatDate(item.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

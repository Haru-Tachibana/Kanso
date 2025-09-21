import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../models/declutter_item.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
      ),
      backgroundColor: AppTheme.pureWhite,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Declutter Complete',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here\'s what you decided to keep and let go.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
                const SizedBox(height: 32),

                // Kept items section
                if (appState.keptItems.isNotEmpty) ...[
                  Text(
                    'Kept (${appState.keptItems.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: appState.keptItems.length,
                      itemBuilder: (context, index) {
                        final item = appState.keptItems[index];
                        return _ItemCard(
                          item: item,
                          isKept: true,
                        );
                      },
                    ),
                  ),
                ],

                // Discarded items section
                if (appState.discardedItems.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Let Go (${appState.discardedItems.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: appState.discardedItems.length,
                      itemBuilder: (context, index) {
                        final item = appState.discardedItems[index];
                        return _ItemCard(
                          item: item,
                          isKept: false,
                        );
                      },
                    ),
                  ),
                ],

                // Empty state
                if (appState.keptItems.isEmpty && appState.discardedItems.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: AppTheme.lightGray,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items processed',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Action buttons
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          appState.clearSession();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('New Session'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          appState.clearSession();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final DeclutterItem item;
  final bool isKept;

  const _ItemCard({
    required this.item,
    required this.isKept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isKept ? AppTheme.lightGray : AppTheme.mediumGray,
          width: 1,
        ),
        color: AppTheme.pureWhite,
      ),
      child: Row(
        children: [
          Icon(
            isKept ? Icons.check_circle : Icons.remove_circle_outline,
            color: isKept ? AppTheme.pureBlack : AppTheme.mediumGray,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
                if (item.memo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.memo!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightGray,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.photoPath != null)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightGray),
                color: AppTheme.pureWhite,
              ),
              child: const Icon(
                Icons.photo,
                color: AppTheme.mediumGray,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

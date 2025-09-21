import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/app_state.dart';
import '../services/theme_service.dart';
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
          // Complete the session and update stats
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appState.completeSession();
          });
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Let Go (${appState.discardedItems.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Navigate to memory creation screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => _MemoryCreationScreen(
                                discardedItems: appState.discardedItems,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Memories'),
                      ),
                    ],
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
            Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.lightGray),
                    color: AppTheme.pureWhite,
                  ),
                  child: Icon(
                    Icons.photo,
                    color: themeService.itemCardIconBg,
                    size: 20,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MemoryCreationScreen extends StatefulWidget {
  final List<DeclutterItem> discardedItems;

  const _MemoryCreationScreen({required this.discardedItems});

  @override
  State<_MemoryCreationScreen> createState() => _MemoryCreationScreenState();
}

class _MemoryCreationScreenState extends State<_MemoryCreationScreen> {
  final Map<String, String> _memories = {};
  final Map<String, String> _photos = {};
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickPhoto(String itemId) async {
    try {
      // Show dialog to choose between camera and gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Photo Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 400,
          maxHeight: 400,
          imageQuality: 80,
        );
        
        if (image != null) {
          setState(() {
            _photos[itemId] = image.path;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppTheme.mediumGray,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Memories'),
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
      ),
      backgroundColor: AppTheme.pureWhite,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add memories for items you\'re letting go',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.mediumGray,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: widget.discardedItems.length,
                itemBuilder: (context, index) {
                  final item = widget.discardedItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.lightGray),
                      color: AppTheme.pureWhite,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _memories[item.id] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Memory or note',
                            hintText: 'What did this item mean to you?',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            _memories[item.id] = value;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickPhoto(item.id),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Add Photo'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (_photos.containsKey(item.id))
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.lightGray),
                                  color: AppTheme.pureWhite,
                                ),
                                child: ClipRect(
                                  child: Image.file(
                                    File(_photos[item.id]!),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.mediumGray),
                        foregroundColor: AppTheme.mediumGray,
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Consumer<ThemeService>(
                    builder: (context, themeService, child) {
                      return SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // Save memories to app state
                            final appState = Provider.of<AppState>(context, listen: false);
                            
                            // Update discarded items with memories and photos
                            for (final item in widget.discardedItems) {
                              if (_memories.containsKey(item.id) || _photos.containsKey(item.id)) {
                                final updatedItem = item.copyWith(
                                  memo: _memories[item.id],
                                  photoPath: _photos[item.id],
                                );
                                appState.updateItem(updatedItem);
                              }
                            }
                            
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Memories saved!'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.only(
                                  top: 50,
                                  left: 20,
                                  right: 20,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeService.saveButtonBg,
                            foregroundColor: AppTheme.pureWhite,
                          ),
                          child: const Text('Save Memories'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

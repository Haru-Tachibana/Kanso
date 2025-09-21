import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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

                // Kept items section (current session only)
                if (appState.currentSessionKeptItems.isNotEmpty) ...[
                  Text(
                    'Kept (${appState.currentSessionKeptItems.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: appState.currentSessionKeptItems.length,
                      itemBuilder: (context, index) {
                        final item = appState.currentSessionKeptItems[index];
                        return _ItemCard(
                          item: item,
                          isKept: true,
                        );
                      },
                    ),
                  ),
                ],

                // Discarded items section (current session only)
                if (appState.currentSessionDiscardedItems.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Let Go (${appState.currentSessionDiscardedItems.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Navigate to memory creation screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => _MemoryCreationScreen(
                                discardedItems: appState.currentSessionDiscardedItems,
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
                      itemCount: appState.currentSessionDiscardedItems.length,
                      itemBuilder: (context, index) {
                        final item = appState.currentSessionDiscardedItems[index];
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

  void _showTopNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.mediumGray,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.pureWhite,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Remove after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

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
          // For web, convert to data URL
          if (kIsWeb) {
            final bytes = await image.readAsBytes();
            final base64 = base64Encode(bytes);
            setState(() {
              _photos[itemId] = 'data:image/jpeg;base64,$base64';
            });
          } else {
            setState(() {
              _photos[itemId] = image.path;
            });
          }
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
                            
                            // Only save items that have memories or photos (user explicitly chose to remember)
                            for (final item in widget.discardedItems) {
                              if (_memories.containsKey(item.id) && _memories[item.id]!.isNotEmpty) {
                                final updatedItem = item.copyWith(
                                  memo: _memories[item.id],
                                  photoPath: _photos[item.id],
                                );
                                appState.updateItem(updatedItem);
                                print('Updated item ${item.id} with memo: ${_memories[item.id]} and photo: ${_photos[item.id]}');
                              } else if (_photos.containsKey(item.id) && _photos[item.id] != null) {
                                final updatedItem = item.copyWith(
                                  memo: _memories[item.id] ?? '',
                                  photoPath: _photos[item.id],
                                );
                                appState.updateItem(updatedItem);
                                print('Updated item ${item.id} with photo: ${_photos[item.id]}');
                              }
                            }
                            print('Total discarded items after save: ${appState.discardedItems.length}');
                            
                            Navigator.of(context).pop();
                            // Show notification at top using Overlay
                            _showTopNotification(context, 'Memories saved!');
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

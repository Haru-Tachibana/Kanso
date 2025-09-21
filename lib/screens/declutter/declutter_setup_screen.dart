import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/theme_service.dart';
import '../../models/declutter_item.dart';
import '../../theme/app_theme.dart';
import 'declutter_process_screen.dart';

class DeclutterSetupScreen extends StatefulWidget {
  const DeclutterSetupScreen({super.key});

  @override
  State<DeclutterSetupScreen> createState() => _DeclutterSetupScreenState();
}

class _DeclutterSetupScreenState extends State<DeclutterSetupScreen> {
  final _itemController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_itemController.text.trim().isEmpty) return;

    final item = DeclutterItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _itemController.text.trim(),
      createdAt: DateTime.now(),
    );

    Provider.of<AppState>(context, listen: false).addItem(item);
    _itemController.clear();
  }

  void _removeItem(String id) {
    Provider.of<AppState>(context, listen: false).removeItem(id);
  }

  void _startDeclutter() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item to declutter'),
        ),
      );
      return;
    }

    // Start a new session
    appState.startNewSession();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DeclutterProcessScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Declutter'),
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
                // Instructions
                Text(
                  'What would you like to declutter?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add items you\'re considering letting go of.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
                const SizedBox(height: 32),

                // Add item form
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _itemController,
                          decoration: const InputDecoration(
                            hintText: 'Enter an item...',
                            border: OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (_) => _addItem(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Consumer<ThemeService>(
                        builder: (context, themeService, child) {
                          return ElevatedButton(
                            onPressed: _addItem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeService.primaryButtonBg,
                              foregroundColor: AppTheme.pureBlack,
                            ),
                            child: const Icon(Icons.add),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Items list
                Expanded(
                  child: appState.items.isEmpty
                      ? Consumer<ThemeService>(
                          builder: (context, themeService, child) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: themeService.secondaryButtonBg,
                                  ),
                              const SizedBox(height: 16),
                              Text(
                                'No items added yet',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.mediumGray,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add items you want to declutter',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.lightGray,
                                ),
                              ),
                                ],
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: appState.items.length,
                          itemBuilder: (context, index) {
                            final item = appState.items[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.lightGray),
                                color: AppTheme.pureWhite,
                              ),
                              child: ListTile(
                                title: Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => _removeItem(item.id),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Start button
                if (appState.items.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Consumer<ThemeService>(
                    builder: (context, themeService, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startDeclutter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeService.primaryButtonBg,
                            foregroundColor: AppTheme.pureBlack,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: Text(
                            'Start Decluttering (${appState.items.length} items)',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.pureBlack,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

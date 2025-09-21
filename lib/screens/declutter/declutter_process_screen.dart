import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../models/declutter_item.dart';
import '../../theme/app_theme.dart';
import '../summary_screen.dart';

class DeclutterProcessScreen extends StatefulWidget {
  const DeclutterProcessScreen({super.key});

  @override
  State<DeclutterProcessScreen> createState() => _DeclutterProcessScreenState();
}

class _DeclutterProcessScreenState extends State<DeclutterProcessScreen>
    with TickerProviderStateMixin {
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _swipeLeft() {
    _swipeItem(false);
  }

  void _swipeRight() {
    _swipeItem(true);
  }

  void _swipeItem(bool keep) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (_currentIndex >= appState.items.length) return;

    final item = appState.items[_currentIndex];
    
    if (keep) {
      appState.keepItem(item);
    } else {
      appState.discardItem(item);
    }

    _swipeController.forward().then((_) {
      setState(() {
        _currentIndex++;
      });
      _swipeController.reset();

      // Check if all items are processed
      if (_currentIndex >= appState.items.length) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SummaryScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Declutter'),
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: AppTheme.pureWhite,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (_currentIndex >= appState.items.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final currentItem = appState.items[_currentIndex];
          final remainingItems = appState.items.length - _currentIndex;

          return Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      '$remainingItems items remaining',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.mediumGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _currentIndex / appState.items.length,
                      backgroundColor: AppTheme.lightGray,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.pureBlack),
                    ),
                  ],
                ),
              ),

              // Swipe card
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _swipeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: _swipeAnimation.value * MediaQuery.of(context).size.width,
                        child: _SwipeCard(
                          item: currentItem,
                          onSwipeLeft: _swipeLeft,
                          onSwipeRight: _swipeRight,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Discard button
                    GestureDetector(
                      onTap: _swipeLeft,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.mediumGray, width: 2),
                          color: AppTheme.pureWhite,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppTheme.mediumGray,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    // Keep button
                    GestureDetector(
                      onTap: _swipeRight,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.pureBlack,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppTheme.pureWhite,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Instructions
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Swipe right to keep • Swipe left to let go',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightGray,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SwipeCard extends StatelessWidget {
  final DeclutterItem item;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const _SwipeCard({
    required this.item,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx > 500) {
          onSwipeRight();
        } else if (details.velocity.pixelsPerSecond.dx < -500) {
          onSwipeLeft();
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.lightGray, width: 2),
          color: AppTheme.pureWhite,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: AppTheme.mediumGray,
                ),
                const SizedBox(height: 24),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    item.description!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  'Does this bring you joy?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightGray,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

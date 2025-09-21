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
  int _totalItems = 0;
  List<DeclutterItem> _sessionItems = [];

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
    
    // Store items locally and total count
    final appState = Provider.of<AppState>(context, listen: false);
    _sessionItems = List.from(appState.items); // Create a copy
    _totalItems = _sessionItems.length;
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
    
    // Safety checks
    if (_currentIndex >= _totalItems || 
        _currentIndex >= _sessionItems.length || 
        _sessionItems.isEmpty ||
        _currentIndex < 0) {
      print('Swipe error: _currentIndex=$_currentIndex, _totalItems=$_totalItems, _sessionItems.length=${_sessionItems.length}');
      return;
    }

    try {
      final item = _sessionItems[_currentIndex];
      
      if (keep) {
        appState.keepItem(item);
      } else {
        appState.discardItem(item);
      }

      setState(() {
        _currentIndex++;
      });

      // Check if all items are processed
      if (_currentIndex >= _totalItems) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SummaryScreen()),
        );
      }
    } catch (e) {
      print('Error in _swipeItem: $e');
      // Navigate to summary screen if there's an error
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SummaryScreen()),
      );
    }
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
          // Safety check for empty items
          if (_sessionItems.isEmpty || _totalItems == 0) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.mediumGray),
                  SizedBox(height: 16),
                  Text('No items to declutter', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          if (_currentIndex >= _totalItems) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final currentItem = _sessionItems[_currentIndex];
          final remainingItems = _totalItems - _currentIndex;

          return SafeArea(
            child: Column(
              children: [
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                        value: _currentIndex / _totalItems,
                        backgroundColor: AppTheme.lightGray,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.pureBlack),
                      ),
                    ],
                  ),
                ),

                // Swipe card
                Expanded(
                  child: Center(
                    child: _SwipeCard(
                      item: currentItem,
                      onSwipeLeft: _swipeLeft,
                      onSwipeRight: _swipeRight,
                    ),
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Swipe right to keep • Swipe left to let go',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightGray,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SwipeCard extends StatefulWidget {
  final DeclutterItem item;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const _SwipeCard({
    required this.item,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  State<_SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<_SwipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _positionAnimation;
  
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _animationController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    
    final velocity = details.velocity.pixelsPerSecond.dx;
    final dragDistance = _dragOffset.dx;
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3; // 30% of screen width
    
    // Determine swipe direction based on velocity and distance
    if (velocity > 500 || dragDistance > threshold) {
      // Swipe right - keep
      _animateSwipe(() => widget.onSwipeRight());
    } else if (velocity < -500 || dragDistance < -threshold) {
      // Swipe left - discard
      _animateSwipe(() => widget.onSwipeLeft());
    } else {
      // Return to center
      _returnToCenter();
    }
  }

  void _animateSwipe(VoidCallback onComplete) {
    // Animate the card off screen
    _animationController.forward().then((_) {
      // Reset position for next card
      setState(() {
        _dragOffset = Offset.zero;
      });
      _animationController.reset();
      // Execute the callback (which will show next card)
      onComplete();
    });
  }

  void _returnToCenter() {
    setState(() {
      _dragOffset = Offset.zero;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;
    final isSwipeRight = _dragOffset.dx > threshold;
    final isSwipeLeft = _dragOffset.dx < -threshold;
    
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: _dragOffset,
            child: Transform.scale(
              scale: _isDragging ? 0.95 : 1.0,
              child: Transform.rotate(
                angle: _dragOffset.dx * 0.0003,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSwipeRight ? Colors.green : 
                             isSwipeLeft ? Colors.red :
                             _isDragging ? AppTheme.mediumGray : AppTheme.lightGray,
                      width: _isDragging ? 3 : 2,
                    ),
                    color: isSwipeRight ? Colors.green.withOpacity(0.1) :
                           isSwipeLeft ? Colors.red.withOpacity(0.1) :
                           AppTheme.pureWhite,
                    boxShadow: _isDragging ? [
                      BoxShadow(
                        color: isSwipeRight ? Colors.green.withOpacity(0.3) :
                               isSwipeLeft ? Colors.red.withOpacity(0.3) :
                               AppTheme.mediumGray.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ] : null,
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
                            widget.item.title,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (widget.item.description != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              widget.item.description!,
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
                          if (_isDragging) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSwipeRight ? Colors.green.withOpacity(0.2) :
                                       isSwipeLeft ? Colors.red.withOpacity(0.2) :
                                       AppTheme.lightGray.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isSwipeRight ? '✓ KEEP' : 
                                isSwipeLeft ? '✗ LET GO' :
                                _dragOffset.dx > 0 ? 'Keep' : 'Let Go',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: isSwipeRight ? Colors.green :
                                         isSwipeLeft ? Colors.red :
                                         _dragOffset.dx > 0 ? AppTheme.pureBlack : AppTheme.mediumGray,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

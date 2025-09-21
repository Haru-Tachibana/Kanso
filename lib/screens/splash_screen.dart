import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _fadeController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Ripple animation controller
    _rippleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _rippleController.repeat(reverse: true);
    _fadeController.forward();

    // Navigate after splash duration
    Future.delayed(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.currentUser != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Karesansui-inspired ripple logo
            AnimatedBuilder(
              animation: _rippleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(120, 120),
                  painter: RipplePainter(
                    progress: _rippleAnimation.value,
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            // App title with fade animation
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        'Kanso',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Simplicity in Living.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for Karesansui-inspired ripple effect
class RipplePainter extends CustomPainter {
  final double progress;

  RipplePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw concentric ripples
    for (int i = 0; i < 3; i++) {
      final radius = (maxRadius * 0.3 * (i + 1)) + 
                    (maxRadius * 0.1 * progress * (i + 1));
      final opacity = (1.0 - (i * 0.3)) * (0.3 + 0.4 * progress);
      
      final paint = Paint()
        ..color = AppTheme.mediumGray.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawCircle(center, radius, paint);
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = AppTheme.pureBlack.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

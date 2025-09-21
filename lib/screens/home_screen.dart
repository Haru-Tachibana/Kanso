import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/theme_service.dart';
import '../services/animation_service.dart';
import '../theme/app_theme.dart';
import 'declutter/declutter_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AnimationService.flowDuration,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AnimationService.flowDuration,
      vsync: this,
    );

    _fadeAnimation = AnimationService.createFadeInFlow(_fadeController);
    _slideAnimation = AnimationService.createSlideInFlow(_slideController);

    // Start animations with flowing sequence
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanso'),
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
      ),
      backgroundColor: AppTheme.pureWhite,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final user = appState.currentUser;
          final totalSessions = appState.totalSessions;
          final totalItemsLetGo = appState.totalItemsLetGo;
          final totalItemsEvaluated = appState.totalItemsEvaluated;

          return AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                // Welcome section
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.name ?? 'Guest',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),

                // Stats section
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Items',
                        value: totalItemsEvaluated.toString(),
                        subtitle: 'Evaluated',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Items',
                        value: totalItemsLetGo.toString(),
                        subtitle: 'Let Go',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Main CTA
                Consumer<ThemeService>(
                  builder: (context, themeService, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DeclutterSetupScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeService.primaryButtonBg,
                          foregroundColor: AppTheme.pureBlack,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: Text(
                          'Start Declutter Session',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.pureBlack,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Recent activity
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Consumer<ThemeService>(
                  builder: (context, themeService, child) {
                    // Show activity if user has completed sessions
                    if (totalSessions > 0) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.lightGray),
                          color: AppTheme.pureWhite,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 24,
                                  color: themeService.primaryButtonBg,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Latest Session Completed',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Evaluated $totalItemsEvaluated items • Let go $totalItemsLetGo items',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.mediumGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 24,
                                  color: themeService.primaryButtonBg,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Progress',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '$totalSessions sessions completed',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.mediumGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Show placeholder if no sessions completed
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.lightGray),
                          color: AppTheme.pureWhite,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: themeService.secondaryButtonBg,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No recent sessions',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.mediumGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start your first declutter session to see activity here.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.lightGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGray),
        color: AppTheme.pureWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}

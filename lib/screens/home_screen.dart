import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'declutter/declutter_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

          return Padding(
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
                        title: 'Sessions',
                        value: totalSessions.toString(),
                        subtitle: 'Completed',
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
                SizedBox(
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
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Text(
                      'Start Declutter Session',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.pureWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Recent activity placeholder
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Container(
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
                        color: AppTheme.lightGray,
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
                ),
              ],
            ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
      ),
      backgroundColor: AppTheme.pureWhite,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final user = appState.currentUser;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.lightGray),
                    color: AppTheme.pureWhite,
                  ),
                  child: Column(
                    children: [
                      // Avatar placeholder
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.lightGray, width: 2),
                          color: AppTheme.pureWhite,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.mediumGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'Guest',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'No email',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Stats section
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        title: 'Sessions',
                        value: appState.totalSessions.toString(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatItem(
                        title: 'Items Let Go',
                        value: appState.totalItemsLetGo.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Settings section
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Language toggle
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.lightGray),
                    color: AppTheme.pureWhite,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.language,
                      color: AppTheme.mediumGray,
                    ),
                    title: const Text('Language'),
                    subtitle: Text(
                      appState.isChinese ? '中文' : 'English',
                      style: const TextStyle(color: AppTheme.mediumGray),
                    ),
                    trailing: Switch(
                      value: appState.isChinese,
                      onChanged: (value) {
                        appState.toggleLanguage();
                      },
                      activeColor: AppTheme.pureBlack,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // About
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.lightGray),
                    color: AppTheme.pureWhite,
                  ),
                  child: const ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: AppTheme.mediumGray,
                    ),
                    title: Text('About Kanso'),
                    subtitle: Text(
                      'Version 1.0.0',
                      style: TextStyle(color: AppTheme.mediumGray),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Help
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.lightGray),
                    color: AppTheme.pureWhite,
                  ),
                  child: const ListTile(
                    leading: Icon(
                      Icons.help_outline,
                      color: AppTheme.mediumGray,
                    ),
                    title: Text('Help & Support'),
                  ),
                ),

                const Spacer(),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showLogoutDialog(context, appState);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.mediumGray),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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

  void _showLogoutDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                appState.logout();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGray),
        color: AppTheme.pureWhite,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}

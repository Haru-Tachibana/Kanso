import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/app_state.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isEditingProfile = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _avatarPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _nameController.text = appState.currentUser?.name ?? '';
    _emailController.text = appState.currentUser?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.currentUser != null) {
      final updatedUser = appState.currentUser!.copyWith(
        name: _nameController.text.trim(),
      );
      appState.updateUser(updatedUser);
    }
    setState(() {
      _isEditingProfile = false;
    });
  }

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

          return SingleChildScrollView(
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
                      // Avatar with edit button
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickAvatar,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.lightGray, width: 2),
                                color: AppTheme.pureWhite,
                              ),
                              child: _avatarPath != null
                                  ? ClipOval(
                                      child: Image.file(
                                        File(_avatarPath!),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppTheme.mediumGray,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickAvatar,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.pureBlack,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 14,
                                  color: AppTheme.pureWhite,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isEditingProfile) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isEditingProfile = false;
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: _saveProfile,
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user?.name ?? 'Guest',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isEditingProfile = true;
                                  _nameController.text = user?.name ?? '';
                                });
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.lightGray,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: AppTheme.pureBlack,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'No email',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ],
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

                // Theme Customizer
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.lightGray),
                    color: AppTheme.pureWhite,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.palette_outlined,
                      color: AppTheme.mediumGray,
                    ),
                    title: const Text('Customize Theme'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showThemeCustomizer(context);
                    },
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

                const SizedBox(height: 32),

                // Logout button
                Consumer<ThemeService>(
                  builder: (context, themeService, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showLogoutDialog(context, appState);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeService.signOutButtonBg,
                          foregroundColor: AppTheme.pureBlack,
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
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 200,
        maxHeight: 200,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _avatarPath = image.path;
        });
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

  void _showThemeCustomizer(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeService>(
          builder: (context, themeService, child) {
            return AlertDialog(
              title: const Text('Customize Theme'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Choose a color to generate your custom greyscale theme:'),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: ThemeService.predefinedColors.length,
                      itemBuilder: (context, index) {
                        final color = ThemeService.predefinedColors[index];
                        final isSelected = themeService.customPrimaryColor == color;
                        return GestureDetector(
                          onTap: () {
                            themeService.setThemeColor(color);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppTheme.pureBlack : AppTheme.lightGray,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              themeService.resetTheme();
                            },
                            child: const Text('Reset to Default'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Done'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

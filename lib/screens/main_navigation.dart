import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'declutter/declutter_setup_screen.dart';
import 'memory_screen.dart';
import 'account_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DeclutterSetupScreen(),
    const MemoryScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Kanso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.clear_all_outlined),
            activeIcon: Icon(Icons.clear_all),
            label: 'Declutter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            activeIcon: Icon(Icons.archive),
            label: 'Memory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

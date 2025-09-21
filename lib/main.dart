import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/app_state.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only for mobile platforms
  if (!kIsWeb) {
    try {
      // Firebase will be initialized here for mobile
      print('Mobile platform detected - Firebase will be initialized');
    } catch (e) {
      print('Firebase initialization failed: $e');
    }
  } else {
    print('Web platform detected - using local storage');
  }
  
  runApp(const KansoApp());
}

class KansoApp extends StatelessWidget {
  const KansoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => ThemeService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Kanso',
            theme: AppTheme.createTheme(themeService),
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

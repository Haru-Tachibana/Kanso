import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'selected_theme_color';
  
  Color _selectedColor = const Color(0xFF000000); // Default black
  Color? _customPrimaryColor;
  
  Color get selectedColor => _selectedColor;
  Color? get customPrimaryColor => _customPrimaryColor;
  
  // Generate greyscale palette based on selected color
  List<Color> get generatedPalette {
    if (_customPrimaryColor == null) {
      return [
        const Color(0xFF000000), // Pure black
        const Color(0xFF333333), // Dark gray
        const Color(0xFF777777), // Medium gray
        const Color(0xFFBBBBBB), // Light gray
        const Color(0xFFFFFFFF), // Pure white
      ];
    }
    
    // Convert selected color to greyscale and generate palette
    final hsl = HSLColor.fromColor(_customPrimaryColor!);
    
    return [
      const Color(0xFF000000), // Pure black (always black)
      HSLColor.fromAHSL(1.0, hsl.hue, hsl.saturation, 0.2).toColor(), // Dark (20% lightness)
      HSLColor.fromAHSL(1.0, hsl.hue, hsl.saturation, 0.5).toColor(), // Medium (50% lightness)
      HSLColor.fromAHSL(1.0, hsl.hue, hsl.saturation, 0.8).toColor(), // Light (80% lightness)
      const Color(0xFFFFFFFF), // Pure white (always white)
    ];
  }
  
  // Get specific colors from palette
  Color get pureBlack => generatedPalette[0];
  Color get darkGray => generatedPalette[1];
  Color get mediumGray => generatedPalette[2];
  Color get lightGray => generatedPalette[3];
  Color get pureWhite => generatedPalette[4];
  
  // Additional theme colors
  Color get mediumGrey => mediumGray; // Alias for consistency
  
  // Button theme colors
  Color get primaryButtonBg => mediumGray; // For main action buttons
  Color get secondaryButtonBg => lightGray; // For secondary/placeholder buttons
  
  // Additional UI element colors
  Color get signOutButtonBg => mediumGray; // For sign out button
  Color get memoryIconBg => lightGray; // For memory page icons
  Color get itemCardIconBg => lightGray; // For item card icons
  Color get saveButtonBg => mediumGray; // For save buttons
  
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_themeKey);
    if (colorValue != null) {
      _customPrimaryColor = Color(colorValue);
      notifyListeners();
    }
  }
  
  Future<void> setThemeColor(Color color) async {
    _customPrimaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, color.value);
    notifyListeners();
  }
  
  Future<void> resetTheme() async {
    _customPrimaryColor = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    notifyListeners();
  }
  
  // Predefined color options
  static const List<Color> predefinedColors = [
    Color(0xFF000000), // Black
    Color(0xFF8B4513), // Brown
    Color(0xFF2F4F4F), // Dark slate gray
    Color(0xFF708090), // Slate gray
    Color(0xFF4682B4), // Steel blue
    Color(0xFF556B2F), // Dark olive green
    Color(0xFF8B008B), // Dark magenta
    Color(0xFFB22222), // Fire brick
    Color(0xFF2E8B57), // Sea green
    Color(0xFFD2691E), // Chocolate
  ];
}

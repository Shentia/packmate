import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

class LiquidGlassTheme {
  // Primary color palette inspired by packmate travel theme
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color secondaryBlue = Color(0xFF5AC8FA);
  static const Color accentTeal = Color(0xFF30D158);
  static const Color backgroundGradientStart = Color(0xFF6366F1);
  static const Color backgroundGradientEnd = Color(0xFF8B5CF6);

  // Glass effect colors
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x1A000000);
  static const Color glassBorder = Color(0x40FFFFFF);

  // Static properties for backward compatibility
  static const Color glassColor = Color(0x1AFFFFFF);
  static const Color borderColor = Color(0x40FFFFFF);
  static const Color textColor = Color(0xFF1D1D1F);
  static const Color accentColor = primaryBlue;
  static const Color backgroundColor = Color(0xFFF2F2F7);

  // Background gradient for scaffolds - static version
  static const LinearGradient staticBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF87CEEB), // Sky blue
      Color(0xFF98FB98), // Pale green
      Color(0xFFF0F8FF), // Alice blue
    ],
  );

  // Travel-themed background colors
  static const List<Color> lightGradient = [
    Color(0xFF87CEEB), // Sky blue
    Color(0xFF98FB98), // Pale green
    Color(0xFFF0F8FF), // Alice blue
  ];

  static const List<Color> darkGradient = [
    Color(0xFF2C3E50), // Dark blue
    Color(0xFF34495E), // Dark gray
    Color(0xFF1A1A2E), // Deep purple
  ];

  // Glassmorphism container decoration
  static BoxDecoration glassContainer(bool isDark, {double borderRadius = 16}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          isDark ? glassLight.withOpacity(0.15) : glassLight.withOpacity(0.25),
          isDark ? glassDark.withOpacity(0.1) : glassDark.withOpacity(0.05),
        ],
      ),
      border: Border.all(color: glassBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(-5, -5),
        ),
      ],
    );
  }

  // Premium button style
  static BoxDecoration premiumButton(bool isDark, {bool isPressed = false}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryBlue.withOpacity(isPressed ? 0.8 : 1.0),
          secondaryBlue.withOpacity(isPressed ? 0.6 : 0.8),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: primaryBlue.withOpacity(0.3),
          blurRadius: isPressed ? 5 : 15,
          offset: Offset(0, isPressed ? 2 : 8),
        ),
      ],
    );
  }

  // Background gradient
  static LinearGradient backgroundGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark ? darkGradient : lightGradient,
    );
  }

  // Cupertino theme data with liquid glass elements
  static CupertinoThemeData cupertinoTheme(bool isDark) {
    return CupertinoThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: Colors.transparent,
      barBackgroundColor: Colors.transparent,
      textTheme: CupertinoTextThemeData(
        primaryColor: isDark ? Colors.white : Colors.black87,
        textStyle: TextStyle(
          inherit: false,
          color: isDark ? Colors.white : Colors.black87,
          fontFamily: '.SF Pro Text',
          fontSize: 16,
          decoration: TextDecoration.none,
        ),
        navTitleTextStyle: TextStyle(
          inherit: false,
          color: isDark ? Colors.white : Colors.black87,
          fontFamily: '.SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  // Glass app bar
  static PreferredSizeWidget glassAppBar({
    required String title,
    required bool isDark,
    List<Widget>? actions,
    Widget? leading,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.white.withOpacity(0.2),
              border: Border(
                bottom: BorderSide(color: glassBorder, width: 0.5),
              ),
            ),
            child: AppBar(
              title: Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: leading,
              actions: actions,
              centerTitle: true,
            ),
          ),
        ),
      ),
    );
  }

  // Travel-themed colors for categories with enhanced liquid glass visibility
  static const Map<String, Color> categoryColors = {
    'Travel': Color(0xFF007AFF),
    'Camping': Color.fromARGB(
      255,
      0,
      0,
      0,
    ), // Changed from green to vibrant teal-cyan for better visibility
    'Beach': Color(0xFF5AC8FA),
    'Business Trip': Color(0xFF9F6000),
    'Hiking': Color(0xFF8E6A5B),
    'Winter': Color(0xFF5E5CE6),
    'Summer': Color(0xFFFF9500),
    'Other': Color(0xFF6B6B6B),
    'Clothing': Color(0xFFFF3B30),
    'Toiletries': Color(0xFF32ADE6),
    'Electronics': Color(0xFF5856D6),
    'Documents': Color(0xFF8E8E93),
  };

  // Get category color
  static Color getCategoryColor(String? category) {
    return categoryColors[category] ?? categoryColors['Other']!;
  }

  // Enhanced liquid glass category badge
  static Widget enhancedCategoryBadge({
    required String category,
    required bool isDark,
    double fontSize = 12,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 4,
    ),
    double borderRadius = 8,
  }) {
    final categoryColor = getCategoryColor(category);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                categoryColor.withOpacity(0.25),
                categoryColor.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: categoryColor.withOpacity(0.4), width: 1),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            category,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: categoryColor,
              shadows: [
                Shadow(
                  color: categoryColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Simplified category badge for backward compatibility
  static Widget categoryBadge(String category, {bool showIcon = false}) {
    final categoryColor = getCategoryColor(category);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                categoryColor.withOpacity(0.25),
                categoryColor.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: categoryColor.withOpacity(0.4), width: 1),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Icon(CupertinoIcons.tag_fill, size: 12, color: categoryColor),
                const SizedBox(width: 4),
              ],
              Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                  shadows: [
                    Shadow(
                      color: categoryColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Floating action button with liquid glass effect
  static Widget liquidGlassFAB({
    required VoidCallback onPressed,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, secondaryBlue],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  // Progress indicator with glass effect
  static Widget glassProgressIndicator({
    required double value,
    required bool isDark,
    double height = 8,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color:
            isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            value == 1.0 ? accentTeal : primaryBlue,
          ),
        ),
      ),
    );
  }
}

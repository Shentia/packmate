import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'screens/packing_lists_screen.dart';
import 'services/theme_service.dart';
import 'services/liquid_glass_theme.dart';
import 'widgets/travel_background.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Get the saved theme
  final themeService = ThemeService();
  final initialTheme = await themeService.getThemeMode();

  runApp(PackingListApp(initialTheme: initialTheme));
}

class PackingListApp extends StatefulWidget {
  final Brightness initialTheme;

  const PackingListApp({super.key, required this.initialTheme});

  @override
  State<PackingListApp> createState() => _PackingListAppState();
}

class _PackingListAppState extends State<PackingListApp> {
  late Brightness _currentTheme;

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.initialTheme;
  }

  void _updateTheme(Brightness newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _currentTheme == Brightness.dark;

    return CupertinoApp(
      title: 'PackMate',
      debugShowCheckedModeBanner: false,
      theme: LiquidGlassTheme.cupertinoTheme(isDark),
      builder: (context, child) {
        return TravelBackgroundWidget(isDark: isDark, child: child!);
      },
      home: PackingListsScreen(
        currentTheme: _currentTheme,
        onThemeChanged: _updateTheme,
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'screens/packing_lists_screen.dart';
import 'services/theme_service.dart';

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
  final ThemeService _themeService = ThemeService();

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
    return CupertinoApp(
      title: 'Packing List',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        brightness: _currentTheme,
        scaffoldBackgroundColor: _currentTheme == Brightness.light 
            ? CupertinoColors.systemGroupedBackground 
            : CupertinoColors.systemBackground.darkColor,
        barBackgroundColor: _currentTheme == Brightness.light 
            ? CupertinoColors.systemBackground 
            : CupertinoColors.systemBackground.darkColor,
      ),
      home: PackingListsScreen(
        currentTheme: _currentTheme,
        onThemeChanged: _updateTheme,
      ),
    );
  }
}

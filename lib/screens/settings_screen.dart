import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/theme_service.dart';
import '../services/file_service.dart';
import '../services/liquid_glass_theme.dart';
import '../widgets/glass_widget.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Brightness) onThemeChanged;
  final Brightness currentTheme;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeService _themeService;
  late bool _isLightMode;
  final FileService _fileService = FileService();

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
    _isLightMode = widget.currentTheme == Brightness.light;
  }

  Future<void> _importPackingList() async {
    final importedList = await _fileService.importPackingList(context);
    if (importedList != null) {
      // Show success message
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text('Import Successful'),
              content: Text('Successfully imported "${importedList.name}"'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.currentTheme == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        middle: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 32),

            // Appearance Section
            _buildGlassSection(
              isDark: isDark,
              title: 'Appearance',
              icon: CupertinoIcons.paintbrush,
              children: [
                _buildGlassListTile(
                  isDark: isDark,
                  title: 'Dark Mode',
                  subtitle: 'Switch between light and dark themes',
                  trailing: CupertinoSwitch(
                    value: !_isLightMode,
                    activeColor: LiquidGlassTheme.primaryBlue,
                    onChanged: (value) async {
                      setState(() {
                        _isLightMode = !value;
                      });
                      final newTheme =
                          _isLightMode ? Brightness.light : Brightness.dark;
                      await _themeService.setThemeMode(newTheme);
                      widget.onThemeChanged(newTheme);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data Management Section
            _buildGlassSection(
              isDark: isDark,
              title: 'Data Management',
              icon: CupertinoIcons.folder,
              children: [
                _buildGlassListTile(
                  isDark: isDark,
                  title: 'Import Packing List',
                  subtitle: 'Import lists from files',
                  trailing: Icon(
                    CupertinoIcons.arrow_down_doc,
                    color: LiquidGlassTheme.primaryBlue,
                  ),
                  onTap: _importPackingList,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // About Section
            _buildGlassSection(
              isDark: isDark,
              title: 'About',
              icon: CupertinoIcons.info_circle,
              children: [
                _buildGlassListTile(
                  isDark: isDark,
                  title: 'Version',
                  subtitle: 'App version information',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          LiquidGlassTheme.primaryBlue,
                          LiquidGlassTheme.secondaryBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '1.0.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                _buildGlassListTile(
                  isDark: isDark,
                  title: 'Help & Feedback',
                  subtitle: 'Get support and send feedback',
                  trailing: Icon(
                    CupertinoIcons.arrow_right,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  onTap: () {
                    // Navigate to help screen or show feedback dialog
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // App Info Card
            GlassWidget(
              isDark: isDark,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          LiquidGlassTheme.primaryBlue,
                          LiquidGlassTheme.secondaryBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      CupertinoIcons.bag,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PackMate',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your intelligent travel companion\n Code with Ahmadreza Shamimi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassSection({
    required bool isDark,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: LiquidGlassTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        GlassWidget(
          isDark: isDark,
          padding: const EdgeInsets.all(4),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildGlassListTile({
    required bool isDark,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              onTap != null
                  ? (isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.02))
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

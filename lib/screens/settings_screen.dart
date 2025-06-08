import 'package:flutter/cupertino.dart';
import '../services/theme_service.dart';
import '../services/file_service.dart';
import '../services/file_service.dart';

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
        builder: (context) => CupertinoAlertDialog(
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
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _buildSectionHeader('Appearance'),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('Dark Mode'),
                  trailing: CupertinoSwitch(
                    value: !_isLightMode,
                    onChanged: (value) async {
                      setState(() {
                        _isLightMode = !value;
                      });
                      final newTheme = _isLightMode ? Brightness.light : Brightness.dark;
                      await _themeService.setThemeMode(newTheme);
                      widget.onThemeChanged(newTheme);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Data Management'),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('Import Packing List'),
                  trailing: const Icon(CupertinoIcons.arrow_down_doc),
                  onTap: _importPackingList,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('About'),
            CupertinoListSection.insetGrouped(
              children: [
                const CupertinoListTile(
                  title: Text('Version'),
                  trailing: Text('1.0.0'),
                ),
                CupertinoListTile(
                  title: const Text('Help & Feedback'),
                  trailing: const Icon(CupertinoIcons.forward),
                  onTap: () {
                    // Navigate to help screen or show feedback dialog
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}

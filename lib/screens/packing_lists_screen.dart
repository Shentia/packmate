import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/packing_list.dart';
import '../services/storage_service.dart';
import '../services/file_service.dart';
import '../services/liquid_glass_theme.dart';
import '../widgets/glass_widget.dart';
import 'list_details_cupertino_screen.dart';
import 'edit_packing_list_screen.dart';
import 'settings_screen.dart';

class PackingListsScreen extends StatefulWidget {
  final Brightness currentTheme;
  final Function(Brightness) onThemeChanged;

  const PackingListsScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<PackingListsScreen> createState() => _PackingListsScreenState();
}

class _PackingListsScreenState extends State<PackingListsScreen>
    with TickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  final FileService _fileService = FileService();
  List<PackingList> _packingLists = [];
  bool _isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadPackingLists();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadPackingLists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lists = await _storageService.getPackingLists();
      setState(() {
        _packingLists = lists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorAlert('Failed to load packing lists');
    }
  }

  void _showErrorAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void _showCreateListDialog() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const EditPackingListScreen()),
    );

    if (result == true) {
      await _loadPackingLists();
    }
  }

  Future<void> _importPackingList() async {
    try {
      final importedList = await _fileService.importPackingList(context);
      if (importedList != null) {
        await _loadPackingLists();
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
    } catch (e) {
      _showErrorAlert('Failed to import packing list: ${e.toString()}');
    }
  }

  Future<void> _deleteList(String listId) async {
    try {
      await _storageService.deletePackingList(listId);
      await _loadPackingLists();
    } catch (e) {
      _showErrorAlert('Failed to delete packing list');
    }
  }

  void _confirmDelete(PackingList list) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Delete Packing List'),
            content: Text('Are you sure you want to delete "${list.name}"?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  _deleteList(list.id);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder:
            (context) => SettingsScreen(
              currentTheme: widget.currentTheme,
              onThemeChanged: widget.onThemeChanged,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.currentTheme == Brightness.dark;

    return CupertinoPageScaffold(
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
                'PackMate',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
          ),
        ),
        trailing: GestureDetector(
          onTap: _navigateToSettings,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(8),
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
                child: const Icon(CupertinoIcons.ellipsis_circle, size: 20),
              ),
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            _isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : _packingLists.isEmpty
                ? _buildEmptyState(isDark)
                : _buildPackingListsView(isDark),
            if (!_isLoading && _packingLists.isNotEmpty)
              _buildFloatingActions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Beautiful icon with glass effect
          GlassWidget(
            isDark: isDark,
            borderRadius: 30,
            padding: const EdgeInsets.all(20),
            child: Icon(
              CupertinoIcons.bag,
              size: 60,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No packing lists yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first packing list\nto get started with your travel planning',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          // Liquid glass buttons
          GlassButton(
            isDark: isDark,
            onPressed: _showCreateListDialog,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.add, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Create Your First List',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassWidget(
                isDark: isDark,
                borderRadius: 12,
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: _importPackingList,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.arrow_down_doc,
                        color: isDark ? Colors.white : Colors.black87,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Import',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackingListsView(bool isDark) {
    _fadeController.forward();
    _slideController.forward();

    return FadeTransition(
      opacity: _fadeController,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        itemCount: _packingLists.length,
        itemBuilder: (context, index) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _slideController,
                curve: Interval(
                  index * 0.1,
                  (index * 0.1) + 0.5,
                  curve: Curves.easeOutBack,
                ),
              ),
            ),
            child: AnimatedGlassWidget(
              isDark: isDark,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              child: _buildPackingListContent(_packingLists[index], isDark),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPackingListContent(PackingList list, bool isDark) {
    final progress = list.progress;
    final progressPercentage = (progress * 100).toInt();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ListDetailsCupertinoScreen(listId: list.id),
            ),
          );
          _loadPackingLists();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      list.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          progressPercentage == 100
                              ? LiquidGlassTheme.accentTeal
                              : LiquidGlassTheme.primaryBlue,
                          progressPercentage == 100
                              ? LiquidGlassTheme.accentTeal.withOpacity(0.7)
                              : LiquidGlassTheme.secondaryBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$progressPercentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _confirmDelete(list),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          CupertinoIcons.delete,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (list.category != null && list.category!.isNotEmpty) ...[
                const SizedBox(height: 8),
                LiquidGlassTheme.enhancedCategoryBadge(
                  category: list.category!,
                  isDark: isDark,
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  borderRadius: 8,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.cube_box,
                    size: 16,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${list.packedItems}/${list.totalItems} items',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  if (list.tripDate != null) ...[
                    Icon(
                      CupertinoIcons.calendar,
                      size: 16,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(list.tripDate!),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              LiquidGlassTheme.glassProgressIndicator(
                value: progress,
                isDark: isDark,
                height: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActions(bool isDark) {
    return Positioned(
      right: 16,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiquidGlassTheme.liquidGlassFAB(
            onPressed: _importPackingList,
            icon: CupertinoIcons.arrow_down_doc,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  LiquidGlassTheme.primaryBlue,
                  LiquidGlassTheme.secondaryBlue,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: LiquidGlassTheme.primaryBlue.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showCreateListDialog,
                borderRadius: BorderRadius.circular(32),
                child: const Icon(
                  CupertinoIcons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import '../models/packing_item.dart';
import '../models/packing_list.dart';
import '../services/storage_service.dart';
import '../services/liquid_glass_theme.dart';
import '../widgets/glass_widget.dart';

import 'edit_packing_list_screen.dart';

class ListDetailsCupertinoScreen extends StatefulWidget {
  final String listId;

  const ListDetailsCupertinoScreen({super.key, required this.listId});

  @override
  State<ListDetailsCupertinoScreen> createState() =>
      _ListDetailsCupertinoScreenState();
}

class _ListDetailsCupertinoScreenState
    extends State<ListDetailsCupertinoScreen> {
  final StorageService _storageService = StorageService();
  PackingList? _packingList;
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadPackingList();
  }

  Future<void> _loadPackingList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lists = await _storageService.getPackingLists();
      final list = lists.firstWhere((list) => list.id == widget.listId);

      setState(() {
        _packingList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorAlert('Failed to load packing list');
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

  void _showAddItemDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(
      text: '1',
    );
    _selectedCategory = null;

    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => Container(
            height: 400,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Add Item',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Add'),
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          return;
                        }

                        int? quantity;
                        try {
                          quantity = int.parse(quantityController.text.trim());
                        } catch (_) {
                          quantity = 1;
                        }

                        final newItem = PackingItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text.trim(),
                          category: _selectedCategory,
                          quantity: quantity,
                          notes:
                              notesController.text.trim().isNotEmpty
                                  ? notesController.text.trim()
                                  : null,
                        );

                        _addItem(newItem);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Item Name',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: nameController,
                  placeholder: 'Enter item name',
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: quantityController,
                  placeholder: 'Enter quantity',
                  padding: const EdgeInsets.all(12),
                  keyboardType: TextInputType.number,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Category (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    _showCategoryPicker();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCategory ?? 'Select a category',
                          style: TextStyle(
                            color:
                                _selectedCategory == null
                                    ? CupertinoColors.systemGrey
                                    : CupertinoColors.label,
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.chevron_down,
                          color: CupertinoColors.systemGrey,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Notes (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: notesController,
                  placeholder: 'Enter notes',
                  padding: const EdgeInsets.all(12),
                  maxLines: 2,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showCategoryPicker() {
    final List<String> categories = [
      'Clothing',
      'Toiletries',
      'Electronics',
      'Documents',
      'Other',
    ];

    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => Container(
            height: 250,
            color: CupertinoColors.systemBackground,
            child: Column(
              children: [
                Container(
                  height: 50,
                  color: CupertinoColors.systemGrey6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      CupertinoButton(
                        child: const Text('Done'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedCategory = categories[index];
                      });
                    },
                    children:
                        categories
                            .map((category) => Center(child: Text(category)))
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _addItem(PackingItem item) async {
    if (_packingList == null) return;

    final updatedList = _packingList!.addItem(item);

    try {
      await _storageService.savePackingList(updatedList);
      await _loadPackingList();
    } catch (e) {
      _showErrorAlert('Failed to add item');
    }
  }

  Future<void> _toggleItemStatus(PackingItem item) async {
    if (_packingList == null) return;

    final updatedItem = item.copyWith(isPacked: !item.isPacked);
    final updatedList = _packingList!.updateItem(updatedItem);

    try {
      await _storageService.savePackingList(updatedList);
      await _loadPackingList();
    } catch (e) {
      _showErrorAlert('Failed to update item');
    }
  }

  void _showEditItemDialog(PackingItem item) {
    final TextEditingController nameController = TextEditingController(
      text: item.name,
    );
    final TextEditingController notesController = TextEditingController(
      text: item.notes ?? '',
    );
    final TextEditingController quantityController = TextEditingController(
      text: item.quantity?.toString() ?? '1',
    );
    _selectedCategory = item.category;

    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => Container(
            height: 400,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Edit Item',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Save'),
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          return;
                        }

                        int? quantity;
                        try {
                          quantity = int.parse(quantityController.text.trim());
                        } catch (_) {
                          quantity = 1;
                        }

                        final updatedItem = item.copyWith(
                          name: nameController.text.trim(),
                          category: _selectedCategory,
                          quantity: quantity,
                          notes:
                              notesController.text.trim().isNotEmpty
                                  ? notesController.text.trim()
                                  : null,
                        );

                        _updateItem(updatedItem);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Item Name',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CupertinoTextField(
                          controller: nameController,
                          placeholder: 'Enter item name',
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CupertinoTextField(
                          controller: quantityController,
                          placeholder: 'Enter quantity',
                          padding: const EdgeInsets.all(12),
                          keyboardType: TextInputType.number,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Category (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            _showCategoryPicker();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedCategory ?? 'Select a category',
                                  style: TextStyle(
                                    color:
                                        _selectedCategory == null
                                            ? CupertinoColors.systemGrey
                                            : CupertinoColors.label,
                                  ),
                                ),
                                const Icon(
                                  CupertinoIcons.chevron_down,
                                  color: CupertinoColors.systemGrey,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Notes (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CupertinoTextField(
                          controller: notesController,
                          placeholder: 'Enter notes',
                          padding: const EdgeInsets.all(12),
                          maxLines: 2,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _updateItem(PackingItem updatedItem) async {
    if (_packingList == null) return;

    final updatedList = _packingList!.updateItem(updatedItem);

    try {
      await _storageService.savePackingList(updatedList);
      await _loadPackingList();
    } catch (e) {
      _showErrorAlert('Failed to update item');
    }
  }

  Future<void> _deleteItem(String itemId) async {
    if (_packingList == null) return;

    final updatedList = _packingList!.removeItem(itemId);

    try {
      await _storageService.savePackingList(updatedList);
      await _loadPackingList();
    } catch (e) {
      _showErrorAlert('Failed to delete item');
    }
  }

  void _confirmDelete(PackingItem item) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Delete Item'),
            content: Text('Are you sure you want to delete "${item.name}"?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  _deleteItem(item.id);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _editPackingList() async {
    if (_packingList == null) return;

    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditPackingListScreen(packingList: _packingList),
      ),
    );

    if (result == true) {
      await _loadPackingList();
    }
  }

  void _exportAndSharePackingList() {
    if (_packingList == null) return;

    try {
      // Convert the packing list to JSON
      final jsonData = jsonEncode(_packingList!.toJson());

      // Share the JSON data
      Share.share(jsonData, subject: '${_packingList!.name} - Packing List');
    } catch (e) {
      _showErrorAlert('Failed to export packing list: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

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
              child: Text(
                _packingList?.name ?? 'Packing List',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        trailing:
            _packingList != null
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${(_packingList!.progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _buildGlassNavButton(
                      icon: CupertinoIcons.share,
                      onPressed: _exportAndSharePackingList,
                      isDark: isDark,
                    ),
                    _buildGlassNavButton(
                      icon: CupertinoIcons.pencil,
                      onPressed: _editPackingList,
                      isDark: isDark,
                    ),
                  ],
                )
                : null,
      ),
      child: Stack(
        children: [
          SafeArea(
            child:
                _isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : _packingList == null
                    ? const Center(child: Text('List not found'))
                    : _packingList!.items.isEmpty
                    ? _buildEmptyState(isDark)
                    : _buildPackingItemsList(isDark),
          ),
          if (_packingList != null && !_isLoading)
            Positioned(
              right: 16,
              bottom: 16,
              child: LiquidGlassTheme.liquidGlassFAB(
                onPressed: _showAddItemDialog,
                icon: CupertinoIcons.add,
                isDark: isDark,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassNavButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: GestureDetector(
        onTap: onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassWidget(
            isDark: isDark,
            borderRadius: 30,
            padding: const EdgeInsets.all(20),
            child: Icon(
              CupertinoIcons.cube_box,
              size: 60,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No items in this list yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your first item to start\npacking for your trip',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          GlassButton(
            isDark: isDark,
            onPressed: _showAddItemDialog,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.add, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Add Your First Item',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackingItemsList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      itemCount: _packingList!.items.length,
      itemBuilder: (context, index) {
        final item = _packingList!.items[index];
        return AnimatedGlassWidget(
          isDark: isDark,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          duration: Duration(milliseconds: 200 + (index * 50)),
          child: _buildPackingItemContent(item, isDark),
        );
      },
    );
  }

  Widget _buildPackingItemContent(PackingItem item, bool isDark) {
    return Row(
      children: [
        // Checkbox with glass effect
        GestureDetector(
          onTap: () => _toggleItemStatus(item),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  item.isPacked
                      ? LinearGradient(
                        colors: [
                          LiquidGlassTheme.accentTeal,
                          LiquidGlassTheme.accentTeal.withOpacity(0.7),
                        ],
                      )
                      : null,
              border: Border.all(
                color:
                    item.isPacked
                        ? LiquidGlassTheme.accentTeal
                        : (isDark ? Colors.white60 : Colors.black26),
                width: 2,
              ),
            ),
            child:
                item.isPacked
                    ? const Icon(
                      CupertinoIcons.check_mark,
                      size: 16,
                      color: Colors.white,
                    )
                    : null,
          ),
        ),
        const SizedBox(width: 16),
        // Item content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: item.isPacked ? TextDecoration.lineThrough : null,
                  color:
                      item.isPacked
                          ? (isDark ? Colors.white54 : Colors.black54)
                          : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              if (item.category != null) ...[
                const SizedBox(height: 4),
                LiquidGlassTheme.enhancedCategoryBadge(
                  category: item.category!,
                  isDark: isDark,
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  borderRadius: 6,
                ),
              ],
              if (item.notes != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.notes!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Quantity and actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.quantity != null && item.quantity! > 1) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: LiquidGlassTheme.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'x${item.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: LiquidGlassTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            GestureDetector(
              onTap: () => _showEditItemDialog(item),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: LiquidGlassTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  CupertinoIcons.pencil,
                  size: 16,
                  color: LiquidGlassTheme.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _confirmDelete(item),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  CupertinoIcons.delete,
                  size: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

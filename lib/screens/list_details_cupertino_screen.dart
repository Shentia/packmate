import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import '../models/packing_item.dart';
import '../models/packing_list.dart';
import '../services/storage_service.dart';
import '../widgets/qr_code_dialog.dart';
import 'edit_packing_list_screen.dart';

class ListDetailsCupertinoScreen extends StatefulWidget {
  final String listId;

  const ListDetailsCupertinoScreen({super.key, required this.listId});

  @override
  State<ListDetailsCupertinoScreen> createState() => _ListDetailsCupertinoScreenState();
}

class _ListDetailsCupertinoScreenState extends State<ListDetailsCupertinoScreen> {
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
      builder: (context) => CupertinoAlertDialog(
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
    final TextEditingController quantityController = TextEditingController(text: '1');
    _selectedCategory = null;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
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
                      notes: notesController.text.trim().isNotEmpty
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
                        color: _selectedCategory == null
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
      builder: (context) => Container(
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
                children: categories
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
    final TextEditingController nameController = TextEditingController(text: item.name);
    final TextEditingController notesController = TextEditingController(text: item.notes ?? '');
    final TextEditingController quantityController = TextEditingController(text: item.quantity?.toString() ?? '1');
    _selectedCategory = item.category;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
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
                      notes: notesController.text.trim().isNotEmpty
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
                                color: _selectedCategory == null
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
      builder: (context) => CupertinoAlertDialog(
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

  void _showQRCodeDialog() {
    if (_packingList == null) return;

    // Using Material dialog since QRCodeDialog is Material-based
    showDialog(
      context: context,
      builder: (context) => QRCodeDialog(packingList: _packingList!),
    );
  }

  void _exportAndSharePackingList() {
    if (_packingList == null) return;

    try {
      // Convert the packing list to JSON
      final jsonData = jsonEncode(_packingList!.toJson());

      // Share the JSON data
      Share.share(
        jsonData,
        subject: '${_packingList!.name} - Packing List',
      );
    } catch (e) {
      _showErrorAlert('Failed to export packing list: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_packingList?.name ?? 'Packing List Details'),
        trailing: _packingList != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_packingList!.progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _showQRCodeDialog,
                    child: const Icon(
                      CupertinoIcons.qrcode,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _exportAndSharePackingList,
                    child: const Icon(
                      CupertinoIcons.share,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _editPackingList,
                    child: const Icon(
                      CupertinoIcons.pencil,
                      size: 22,
                    ),
                  ),
                ],
              )
            : null,
      ),
      child: Stack(
        children: [
          SafeArea(
            child: _isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : _packingList == null
                    ? const Center(child: Text('List not found'))
                    : _packingList!.items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'No items in this list yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                CupertinoButton.filled(
                                  onPressed: _showAddItemDialog,
                                  child: const Text('Add Your First Item'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80), // Add padding for FAB
                            itemCount: _packingList!.items.length,
                            itemBuilder: (context, index) {
                              final item = _packingList!.items[index];
                              return _buildPackingItemTile(item);
                            },
                          ),
          ),
          if (_packingList != null && !_isLoading)
            Positioned(
              right: 16,
              bottom: 16,
              child: GestureDetector(
                onTap: _showAddItemDialog,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.add,
                    color: CupertinoColors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPackingItemTile(PackingItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CupertinoColors.systemGrey5,
          width: 1,
        ),
      ),
      child: CupertinoListTile(
        leading: GestureDetector(
          onTap: () => _toggleItemStatus(item),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: item.isPacked
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: item.isPacked
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.systemGrey,
                width: 2,
              ),
            ),
            child: item.isPacked
                ? const Icon(
                    CupertinoIcons.check_mark,
                    size: 16,
                    color: CupertinoColors.white,
                  )
                : null,
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isPacked ? TextDecoration.lineThrough : null,
            color: item.isPacked
                ? CupertinoColors.systemGrey
                : CupertinoColors.label,
          ),
        ),
        subtitle: item.category != null
            ? Text(
                item.category!,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.quantity != null && item.quantity! > 1)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  'x${item.quantity}',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showEditItemDialog(item),
              child: const Icon(
                CupertinoIcons.pencil,
                color: CupertinoColors.activeBlue,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _confirmDelete(item),
              child: const Icon(
                CupertinoIcons.delete,
                color: CupertinoColors.systemRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

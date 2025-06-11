import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/packing_item.dart';
import '../models/packing_list.dart';
import '../services/storage_service.dart';
import '../widgets/packing_item_tile.dart';

class ListDetailsScreen extends StatefulWidget {
  final String listId;

  const ListDetailsScreen({super.key, required this.listId});

  @override
  State<ListDetailsScreen> createState() => _ListDetailsScreenState();
}

class _ListDetailsScreenState extends State<ListDetailsScreen> {
  final StorageService _storageService = StorageService();
  PackingList? _packingList;
  bool _isLoading = true;

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
      _showErrorSnackBar('Failed to load packing list');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAddItemDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(
      text: '1',
    );
    String? selectedCategory;

    showDialog(
      context: context,
      builder:
          (context) => Material(
            type: MaterialType.transparency,
            child: AlertDialog(
              title: const Text('Add Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        hintText: 'Enter item name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Enter quantity',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category (Optional)',
                      ),
                      value: selectedCategory,
                      items: const [
                        DropdownMenuItem(
                          value: 'Clothing',
                          child: Text('Clothing'),
                        ),
                        DropdownMenuItem(
                          value: 'Toiletries',
                          child: Text('Toiletries'),
                        ),
                        DropdownMenuItem(
                          value: 'Electronics',
                          child: Text('Electronics'),
                        ),
                        DropdownMenuItem(
                          value: 'Documents',
                          child: Text('Documents'),
                        ),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        selectedCategory = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Enter notes',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
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
                      id: const Uuid().v4(),
                      name: nameController.text.trim(),
                      category: selectedCategory,
                      quantity: quantity,
                      notes:
                          notesController.text.trim().isNotEmpty
                              ? notesController.text.trim()
                              : null,
                    );

                    _addItem(newItem);
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
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
      _showErrorSnackBar('Failed to add item');
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
      _showErrorSnackBar('Failed to update item');
    }
  }

  Future<void> _deleteItem(String itemId) async {
    if (_packingList == null) return;

    final updatedList = _packingList!.removeItem(itemId);

    try {
      await _storageService.savePackingList(updatedList);
      await _loadPackingList();
    } catch (e) {
      _showErrorSnackBar('Failed to delete item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_packingList?.name ?? 'Packing List Details'),
        actions: [
          if (_packingList != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${(_packingList!.progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _packingList == null
              ? const Center(child: Text('List not found'))
              : _packingList!.items.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No items in this list yet',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showAddItemDialog,
                      child: const Text('Add Your First Item'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _packingList!.items.length,
                itemBuilder: (context, index) {
                  final item = _packingList!.items[index];
                  return PackingItemTile(
                    item: item,
                    onToggle: _toggleItemStatus,
                    onDelete: _deleteItem,
                  );
                },
              ),
      floatingActionButton:
          _packingList == null || _packingList!.items.isEmpty
              ? null
              : FloatingActionButton(
                onPressed: _showAddItemDialog,
                child: const Icon(Icons.add),
              ),
    );
  }
}

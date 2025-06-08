import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/packing_item.dart';
import '../models/packing_list.dart';
import '../services/storage_service.dart';

class EditPackingListScreen extends StatefulWidget {
  final PackingList? packingList; // If null, we're creating a new list

  const EditPackingListScreen({super.key, this.packingList});

  @override
  State<EditPackingListScreen> createState() => _EditPackingListScreenState();
}

class _EditPackingListScreenState extends State<EditPackingListScreen> {
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  final List<ItemFormField> _itemFields = [];
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _isEditing = widget.packingList != null;
    
    if (_isEditing) {
      // Populate form with existing data
      _titleController.text = widget.packingList!.name;
      if (widget.packingList!.category != null) {
        _categoryController.text = widget.packingList!.category!;
      }
      if (widget.packingList!.description != null) {
        _descriptionController.text = widget.packingList!.description!;
      }
      
      // Add existing items
      for (var item in widget.packingList!.items) {
        _itemFields.add(ItemFormField(
          controller: TextEditingController(text: item.name),
          isPacked: item.isPacked,
          id: item.id,
        ));
      }
    } else {
      // Add one empty item field by default for new lists
      _addNewItemField();
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    for (var field in _itemFields) {
      field.controller.dispose();
    }
    super.dispose();
  }
  
  void _addNewItemField() {
    setState(() {
      _itemFields.add(ItemFormField(
        controller: TextEditingController(),
        isPacked: false,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      ));
    });
  }
  
  void _removeItemField(int index) {
    setState(() {
      _itemFields[index].controller.dispose();
      _itemFields.removeAt(index);
    });
  }
  
  void _toggleItemPacked(int index) {
    setState(() {
      _itemFields[index].isPacked = !_itemFields[index].isPacked;
    });
  }
  
  Future<void> _savePackingList() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Create list of items
    final items = _itemFields
        .where((field) => field.controller.text.trim().isNotEmpty)
        .map((field) => PackingItem(
              id: field.id,
              name: field.controller.text.trim(),
              isPacked: field.isPacked,
            ))
        .toList();
    
    // Create or update packing list
    final packingList = PackingList(
      id: _isEditing ? widget.packingList!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _titleController.text.trim(),
      category: _categoryController.text.trim().isNotEmpty ? _categoryController.text.trim() : null,
      createdAt: _isEditing ? widget.packingList!.createdAt : DateTime.now(),
      items: items,
      description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
    );
    
    try {
      await _storageService.savePackingList(packingList);
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      _showErrorAlert('Failed to save packing list');
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
  
  void _showCategoryPicker() {
    final List<String> categories = [
      'Travel',
      'Camping',
      'Beach',
      'Business Trip',
      'Hiking',
      'Winter',
      'Summer',
      'Other',
    ];
    
    String selectedCategory = _categoryController.text;
    
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
                      setState(() {
                        _categoryController.text = selectedCategory;
                      });
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
                  selectedCategory = categories[index];
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
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditing ? 'Edit Packing List' : 'Create Packing List'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Save'),
          onPressed: _savePackingList,
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Title Section
              const Text(
                'Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CupertinoTextFormFieldRow(
                controller: _titleController,
                placeholder: 'Enter list title',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              
              const SizedBox(height: 16),
              
              // Category Section
              const Text(
                'Category (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showCategoryPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _categoryController.text.isEmpty ? 'Select a category' : _categoryController.text,
                        style: TextStyle(
                          color: _categoryController.text.isEmpty
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
              
              // Description Section
              const Text(
                'Description (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CupertinoTextFormFieldRow(
                controller: _descriptionController,
                placeholder: 'Enter description',
                maxLines: 3,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              
              const SizedBox(height: 24),
              
              // Items Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Row(
                      children: [
                        Icon(CupertinoIcons.add_circled),
                        SizedBox(width: 4),
                        Text('Add Item'),
                      ],
                    ),
                    onPressed: _addNewItemField,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Item List
              ..._buildItemFields(),
              
              const SizedBox(height: 24),
              
              // Save Button
              CupertinoButton.filled(
                onPressed: _savePackingList,
                child: Text(_isEditing ? 'Update Packing List' : 'Create Packing List'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  List<Widget> _buildItemFields() {
    return List.generate(_itemFields.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => _toggleItemPacked(index),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _itemFields[index].isPacked
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _itemFields[index].isPacked
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey,
                    width: 2,
                  ),
                ),
                child: _itemFields[index].isPacked
                    ? const Icon(
                        CupertinoIcons.check_mark,
                        size: 16,
                        color: CupertinoColors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            
            // Text Field
            Expanded(
              child: CupertinoTextFormFieldRow(
                controller: _itemFields[index].controller,
                placeholder: 'Enter item name',
                validator: (value) {
                  if (index == 0 && (value == null || value.trim().isEmpty)) {
                    return 'Please enter at least one item';
                  }
                  return null;
                },
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            
            // Delete Button
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _removeItemField(index),
              child: const Icon(
                CupertinoIcons.delete,
                color: CupertinoColors.systemRed,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// Helper class for item form fields
class ItemFormField {
  final TextEditingController controller;
  bool isPacked;
  final String id;
  
  ItemFormField({
    required this.controller,
    required this.isPacked,
    required this.id,
  });
}
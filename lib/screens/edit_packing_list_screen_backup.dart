import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/packing_item.dart';
import '../models/packing_list.dart';
import '../services/storage_service.dart';
import '../services/liquid_glass_theme.dart';
import '../widgets/glass_widget.dart';

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
        _itemFields.add(
          ItemFormField(
            controller: TextEditingController(text: item.name),
            isPacked: item.isPacked,
            id: item.id,
          ),
        );
      }
    } else {
      // Add one empty field for new lists
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
      _itemFields.add(
        ItemFormField(
          controller: TextEditingController(),
          isPacked: false,
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      );
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
    final items =
        _itemFields
            .where((field) => field.controller.text.trim().isNotEmpty)
            .map(
              (field) => PackingItem(
                id: field.id,
                name: field.controller.text.trim(),
                isPacked: field.isPacked,
              ),
            )
            .toList();

    // Create or update packing list
    final packingList = PackingList(
      id:
          _isEditing
              ? widget.packingList!.id
              : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _titleController.text.trim(),
      category:
          _categoryController.text.trim().isNotEmpty
              ? _categoryController.text.trim()
              : null,
      createdAt: _isEditing ? widget.packingList!.createdAt : DateTime.now(),
      items: items,
      description:
          _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
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
                _isEditing ? 'Edit List' : 'Create List',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            'Save',
            style: TextStyle(
              color: LiquidGlassTheme.primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: _savePackingList,
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Title Section with Glass Container
                _buildSection(
                  isDark: isDark,
                  title: 'List Details',
                  icon: CupertinoIcons.list_bullet,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Title', true),
                      const SizedBox(height: 8),
                      _buildGlassTextField(
                        controller: _titleController,
                        placeholder: 'Enter list title',
                        isDark: isDark,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildLabel('Category', false),
                      const SizedBox(height: 8),
                      _buildCategorySelector(isDark),

                      const SizedBox(height: 20),

                      _buildLabel('Description', false),
                      const SizedBox(height: 8),
                      _buildGlassTextField(
                        controller: _descriptionController,
                        placeholder: 'Enter description (optional)',
                        isDark: isDark,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Items Section with Glass Container
                _buildSection(
                  isDark: isDark,
                  title: 'Items',
                  icon: CupertinoIcons.cube_box,
                  trailing: _buildAddItemButton(isDark),
                  child: Column(
                    children: [
                      if (_itemFields.isEmpty)
                        _buildEmptyItemsState(isDark)
                      else
                        ..._buildItemFields(isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Save Button
                _buildSaveButton(isDark),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for building UI components
  Widget _buildSection({
    required bool isDark,
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return GlassWidget(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      LiquidGlassTheme.primaryBlue,
                      LiquidGlassTheme.secondaryBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isRequired) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.label,
        ),
        children: [
          if (isRequired)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String placeholder,
    required bool isDark,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: CupertinoTextFormFieldRow(
            controller: controller,
            placeholder: placeholder,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            decoration: const BoxDecoration(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            placeholderStyle: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return GestureDetector(
      onTap: _showCategoryPicker,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (_categoryController.text.isNotEmpty) ...[
                        LiquidGlassTheme.enhancedCategoryBadge(
                          category: _categoryController.text,
                          isDark: isDark,
                          fontSize: 12,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          borderRadius: 6,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          _categoryController.text.isEmpty
                              ? 'Select a category'
                              : _categoryController.text,
                          style: TextStyle(
                            color:
                                _categoryController.text.isEmpty
                                    ? (isDark ? Colors.white60 : Colors.black54)
                                    : (isDark ? Colors.white : Colors.black87),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_down,
                  color: isDark ? Colors.white60 : Colors.black54,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddItemButton(bool isDark) {
    return GestureDetector(
      onTap: _addNewItemField,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              LiquidGlassTheme.primaryBlue,
              LiquidGlassTheme.secondaryBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: LiquidGlassTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.add_circled_solid,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            const Text(
              'Add Item',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyItemsState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.cube_box,
              size: 32,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No items yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Add Item" to start building your packing list',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItemFields(bool isDark) {
    return List.generate(_itemFields.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.03)
                        : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Custom checkbox with liquid glass styling
                  GestureDetector(
                    onTap: () => _toggleItemPacked(index),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient:
                            _itemFields[index].isPacked
                                ? LinearGradient(
                                  colors: [
                                    LiquidGlassTheme.accentTeal,
                                    LiquidGlassTheme.accentTeal.withOpacity(
                                      0.8,
                                    ),
                                  ],
                                )
                                : null,
                        border: Border.all(
                          color:
                              _itemFields[index].isPacked
                                  ? LiquidGlassTheme.accentTeal
                                  : (isDark
                                      ? Colors.white.withOpacity(0.4)
                                      : Colors.black26),
                          width: 2,
                        ),
                      ),
                      child:
                          _itemFields[index].isPacked
                              ? const Icon(
                                CupertinoIcons.check_mark,
                                size: 16,
                                color: Colors.white,
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text Field with glass styling
                  Expanded(
                    child: CupertinoTextField(
                      controller: _itemFields[index].controller,
                      placeholder: 'Enter item name',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        decoration:
                            _itemFields[index].isPacked
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                      placeholderStyle: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                      decoration: const BoxDecoration(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Delete button
                  GestureDetector(
                    onTap: () => _removeItemField(index),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        CupertinoIcons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSaveButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            LiquidGlassTheme.primaryBlue,
            LiquidGlassTheme.secondaryBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
          onTap: _savePackingList,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              _isEditing ? 'Update Packing List' : 'Create Packing List',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:ui';
import '../models/packing_list.dart';
import '../models/packing_item.dart';
import '../services/liquid_glass_theme.dart';
import '../widgets/glass_widget.dart';

class EditPackingListScreen extends StatefulWidget {
  final PackingList? packingList;
  final String? initialCategory;

  const EditPackingListScreen({
    super.key,
    this.packingList,
    this.initialCategory,
  });

  @override
  State<EditPackingListScreen> createState() => _EditPackingListScreenState();
}

class _EditPackingListScreenState extends State<EditPackingListScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;
  List<PackingItem> _items = [];
  List<TextEditingController> _itemControllers = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.packingList?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.packingList?.description ?? '',
    );
    _selectedCategory = widget.packingList?.category ?? widget.initialCategory;

    if (widget.packingList != null) {
      _items = List.from(widget.packingList!.items);
      _itemControllers =
          _items.map((item) => TextEditingController(text: item.name)).toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: LiquidGlassTheme.glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LiquidGlassTheme.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: LiquidGlassTheme.accentColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: LiquidGlassTheme.textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: LiquidGlassTheme.textColor,
            ),
          ),
          if (required)
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: LiquidGlassTheme.textColor, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: LiquidGlassTheme.textColor.withOpacity(0.6),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Category', required: true),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onPressed: _showCategoryPicker,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _selectedCategory != null
                    ? LiquidGlassTheme.categoryBadge(
                      _selectedCategory!,
                      showIcon: true,
                    )
                    : Text(
                      'Select Category',
                      style: TextStyle(
                        color: LiquidGlassTheme.textColor.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                Icon(
                  CupertinoIcons.chevron_down,
                  color: LiquidGlassTheme.textColor.withOpacity(0.6),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => Container(
            height: 300,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 32.0,
                scrollController: FixedExtentScrollController(
                  initialItem:
                      _selectedCategory != null
                          ? LiquidGlassTheme.categoryColors.keys
                              .toList()
                              .indexOf(_selectedCategory!)
                          : 0,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedCategory =
                        LiquidGlassTheme.categoryColors.keys.toList()[index];
                  });
                },
                children:
                    LiquidGlassTheme.categoryColors.keys.map((category) {
                      return Center(
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 18),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
    );
  }

  Widget _buildAddItemButton() {
    return GlassButton(
      isDark: false, // Add missing isDark parameter
      onPressed: _addItem,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.add,
            color: LiquidGlassTheme.accentColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Add Item',
            style: TextStyle(
              color: LiquidGlassTheme.accentColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyItemsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.cube_box,
            size: 48,
            color: LiquidGlassTheme.textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No items added yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: LiquidGlassTheme.textColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first packing item below',
            style: TextStyle(
              fontSize: 14,
              color: LiquidGlassTheme.textColor.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemFields() {
    if (_items.isEmpty) {
      return _buildEmptyItemsState();
    }

    return Column(
      children: List.generate(_items.length, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Custom checkbox
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _items[index] = _items[index].copyWith(
                        isPacked: !_items[index].isPacked,
                      );
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          _items[index].isPacked
                              ? LiquidGlassTheme.accentColor
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            _items[index].isPacked
                                ? LiquidGlassTheme.accentColor
                                : Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child:
                        _items[index].isPacked
                            ? const Icon(
                              CupertinoIcons.checkmark,
                              size: 16,
                              color: Colors.white,
                            )
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Item name field
                Expanded(
                  child: TextFormField(
                    controller: _itemControllers[index],
                    style: const TextStyle(
                      color: LiquidGlassTheme.textColor,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Item name',
                      hintStyle: TextStyle(
                        color: LiquidGlassTheme.textColor.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      _items[index] = _items[index].copyWith(name: value);
                    },
                  ),
                ),
                // Delete button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _removeItem(index),
                  child: Icon(
                    CupertinoIcons.trash,
                    color: Colors.red.withOpacity(0.7),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LiquidGlassTheme.accentColor,
            LiquidGlassTheme.accentColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: LiquidGlassTheme.accentColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _savePackingList,
        child: const Text(
          'Save Packing List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _addItem() {
    setState(() {
      final newItem = PackingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        isPacked: false,
      );
      _items.add(newItem);
      _itemControllers.add(TextEditingController());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemControllers[index].dispose();
      _itemControllers.removeAt(index);
      _items.removeAt(index);
    });
  }

  void _savePackingList() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        _showErrorDialog('Please select a category');
        return;
      }

      if (_nameController.text.trim().isEmpty) {
        _showErrorDialog('Please enter a list name');
        return;
      }

      // Update item names from controllers
      for (int i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(name: _itemControllers[i].text.trim());
      }

      // Remove empty items
      _items.removeWhere((item) => item.name.isEmpty);

      final packingList = PackingList(
        id:
            widget.packingList?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        items: _items,
        createdAt: widget.packingList?.createdAt ?? DateTime.now(),
      );

      Navigator.pop(context, packingList);
    }
  }

  void _showErrorDialog(String message) {
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: LiquidGlassTheme.backgroundColor,
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LiquidGlassTheme.staticBackgroundGradient,
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Navigation bar with glass effect
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: LiquidGlassTheme.glassColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: LiquidGlassTheme.borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.pop(context),
                              child: Icon(
                                CupertinoIcons.back,
                                color: LiquidGlassTheme.accentColor,
                                size: 24,
                              ),
                            ),
                            Text(
                              widget.packingList != null
                                  ? 'Edit List'
                                  : 'New List',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: LiquidGlassTheme.textColor,
                              ),
                            ),
                            const SizedBox(
                              width: 44,
                            ), // Balance the back button
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: Localizations(
                    locale: const Locale('en', 'US'),
                    delegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    child: Material(
                      type: MaterialType.transparency,
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // List Details Section
                              _buildSection(
                                title: 'List Details',
                                icon: CupertinoIcons.info_circle,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Name', required: true),
                                    _buildGlassTextField(
                                      controller: _nameController,
                                      hint: 'Enter list name',
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'List name is required';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    _buildLabel('Description'),
                                    _buildGlassTextField(
                                      controller: _descriptionController,
                                      hint: 'Enter description (optional)',
                                      maxLines: 3,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildCategorySelector(),
                                  ],
                                ),
                              ),
                              // Items Section
                              _buildSection(
                                title: 'Items (${_items.length})',
                                icon: CupertinoIcons.cube_box,
                                child: Column(
                                  children: [
                                    _buildItemFields(),
                                    const SizedBox(height: 16),
                                    _buildAddItemButton(),
                                  ],
                                ),
                              ),
                              // Save Button
                              Padding(
                                padding: const EdgeInsets.only(bottom: 32),
                                child: _buildSaveButton(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

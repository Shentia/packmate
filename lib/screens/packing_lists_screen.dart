import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/packing_list.dart';
import '../services/storage_service.dart';
import '../services/file_service.dart';
import 'list_details_cupertino_screen.dart';
import 'edit_packing_list_screen.dart';
import 'settings_screen.dart';
import 'qr_scanner_screen.dart';

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

class _PackingListsScreenState extends State<PackingListsScreen> {
  final StorageService _storageService = StorageService();
  final FileService _fileService = FileService();
  List<PackingList> _packingLists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackingLists();
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

  void _showCreateListDialog() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const EditPackingListScreen(),
      ),
    );

    if (result == true) {
      await _loadPackingLists();
    }
  }

  Future<void> _saveNewList(PackingList list) async {
    try {
      await _storageService.savePackingList(list);
      await _loadPackingLists();
    } catch (e) {
      _showErrorAlert('Failed to save packing list');
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
      builder: (context) => CupertinoAlertDialog(
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

  Future<void> _scanQRCode() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );

    if (result == true) {
      await _loadPackingLists();
    }
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => SettingsScreen(
          currentTheme: widget.currentTheme,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Packing Lists'),
        trailing: GestureDetector(
          onTap: _navigateToSettings,
          child: const Icon(CupertinoIcons.ellipsis_circle),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _packingLists.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No packing lists yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoButton.filled(
                          onPressed: _showCreateListDialog,
                          child: const Text('Create Your First List'),
                        ),
                        const SizedBox(height: 8),
                        CupertinoButton(
                          onPressed: _importPackingList,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.arrow_down_doc),
                              SizedBox(width: 5),
                              Text('Import Existing List'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        CupertinoButton(
                          onPressed: _scanQRCode,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.qrcode_viewfinder),
                              SizedBox(width: 5),
                              Text('Scan QR Code'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _packingLists.length,
                          itemBuilder: (context, index) {
                            final list = _packingLists[index];
                            return _buildPackingListItem(list);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CupertinoButton.filled(
                              onPressed: _showCreateListDialog,
                              child: const Text('Create New List'),
                            ),
                            const SizedBox(width: 10),
                            CupertinoButton(
                              onPressed: _importPackingList,
                              child: const Icon(CupertinoIcons.arrow_down_doc),
                            ),
                            const SizedBox(width: 10),
                            CupertinoButton(
                              onPressed: _scanQRCode,
                              child: const Icon(CupertinoIcons.qrcode_viewfinder),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildPackingListItem(PackingList list) {
    final progress = list.progress;
    final progressPercentage = (progress * 100).toInt();

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ListDetailsCupertinoScreen(listId: list.id),
          ),
        );
        _loadPackingLists(); // Refresh after returning
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey5.withOpacity(0.5),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      list.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _confirmDelete(list),
                    child: const Icon(
                      CupertinoIcons.delete,
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                ],
              ),
              if (list.category != null && list.category!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    list.category!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Items: ${list.packedItems}/${list.totalItems}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$progressPercentage%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: progressPercentage == 100
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: CupertinoColors.systemGrey5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 1.0
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.activeBlue,
                  ),
                  minHeight: 6,
                ),
              ),
              if (list.tripDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.calendar,
                        size: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(list.tripDate!),
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/packing_list.dart';
import '../services/storage_service.dart';
import '../widgets/packing_list_card.dart';
import 'list_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
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
      _showErrorSnackBar('Failed to load packing lists');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showCreateListDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Packing List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'List Name',
                hintText: 'Enter a name for your packing list',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter a description',
              ),
              maxLines: 2,
            ),
          ],
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

              final newList = PackingList(
                id: const Uuid().v4(),
                name: nameController.text.trim(),
                createdAt: DateTime.now(),
                items: [],
                description: descriptionController.text.trim().isNotEmpty 
                    ? descriptionController.text.trim() 
                    : null,
              );

              _saveNewList(newList);
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNewList(PackingList list) async {
    try {
      await _storageService.savePackingList(list);
      await _loadPackingLists();
    } catch (e) {
      _showErrorSnackBar('Failed to save packing list');
    }
  }

  Future<void> _deleteList(String listId) async {
    try {
      await _storageService.deletePackingList(listId);
      await _loadPackingLists();
    } catch (e) {
      _showErrorSnackBar('Failed to delete packing list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Packing List'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _packingLists.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No packing lists yet',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showCreateListDialog,
                        child: const Text('Create Your First List'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _packingLists.length,
                  itemBuilder: (context, index) {
                    final list = _packingLists[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: PackingListCard(
                        packingList: list,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListDetailsScreen(listId: list.id),
                            ),
                          );
                          _loadPackingLists(); // Refresh after returning
                        },
                        onDelete: () => _deleteList(list.id),
                      ),
                    );
                  },
                ),
      floatingActionButton: _packingLists.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _showCreateListDialog,
              child: const Icon(Icons.add),
            ),
    );
  }
}

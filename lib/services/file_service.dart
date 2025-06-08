import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import '../models/packing_list.dart';
import 'storage_service.dart';

class FileService {
  final StorageService _storageService = StorageService();

  /// Imports a packing list from a JSON file
  /// Returns the imported packing list if successful, null otherwise
  Future<PackingList?> importPackingList(BuildContext context) async {
    try {
      // Pick a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return null; // User canceled the picker
      }

      // Get the file path
      final file = result.files.first;
      String? filePath = file.path;
      
      if (filePath == null) {
        _showErrorDialog(context, 'Could not access the file path');
        return null;
      }

      // Read the file content
      final fileContent = await File(filePath).readAsString();
      
      // Parse the JSON
      final Map<String, dynamic> jsonData = jsonDecode(fileContent);
      
      // Create a PackingList from the JSON
      final PackingList importedList = PackingList.fromJson(jsonData);
      
      // Save the imported list
      await _storageService.savePackingList(importedList);
      
      return importedList;
    } catch (e) {
      _showErrorDialog(context, 'Error importing file: ${e.toString()}');
      return null;
    }
  }

  /// Shows an error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Import Error'),
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
}
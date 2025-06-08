import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/packing_list.dart';

class StorageService {
  static const String _listsKey = 'packing_lists';

  // Save all packing lists
  Future<void> savePackingLists(List<PackingList> lists) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLists = lists.map((list) => jsonEncode(list.toJson())).toList();
    await prefs.setStringList(_listsKey, jsonLists);
  }

  // Get all packing lists
  Future<List<PackingList>> getPackingLists() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLists = prefs.getStringList(_listsKey) ?? [];
    
    return jsonLists.map((jsonList) {
      final Map<String, dynamic> listMap = jsonDecode(jsonList);
      return PackingList.fromJson(listMap);
    }).toList();
  }

  // Save a single packing list
  Future<void> savePackingList(PackingList list) async {
    final lists = await getPackingLists();
    final existingIndex = lists.indexWhere((l) => l.id == list.id);
    
    if (existingIndex >= 0) {
      lists[existingIndex] = list;
    } else {
      lists.add(list);
    }
    
    await savePackingLists(lists);
  }

  // Delete a packing list
  Future<void> deletePackingList(String listId) async {
    final lists = await getPackingLists();
    final updatedLists = lists.where((list) => list.id != listId).toList();
    await savePackingLists(updatedLists);
  }

  // Clear all data (for testing or reset functionality)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_listsKey);
  }
}
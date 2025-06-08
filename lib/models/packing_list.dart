import 'package:flutter/foundation.dart';
import 'packing_item.dart';

class PackingList {
  final String id;
  final String name;
  final String? category;
  final DateTime createdAt;
  final DateTime? tripDate;
  final List<PackingItem> items;
  final String? description;

  PackingList({
    required this.id,
    required this.name,
    this.category,
    required this.createdAt,
    this.tripDate,
    required this.items,
    this.description,
  });

  int get totalItems => items.length;

  int get packedItems => items.where((item) => item.isPacked).length;

  double get progress => totalItems == 0 ? 0 : packedItems / totalItems;

  PackingList copyWith({
    String? id,
    String? name,
    String? category,
    DateTime? createdAt,
    DateTime? tripDate,
    List<PackingItem>? items,
    String? description,
  }) {
    return PackingList(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      tripDate: tripDate ?? this.tripDate,
      items: items ?? this.items,
      description: description ?? this.description,
    );
  }

  PackingList addItem(PackingItem item) {
    final newItems = List<PackingItem>.from(items)..add(item);
    return copyWith(items: newItems);
  }

  PackingList updateItem(PackingItem updatedItem) {
    final newItems = items.map((item) => 
      item.id == updatedItem.id ? updatedItem : item
    ).toList();
    return copyWith(items: newItems);
  }

  PackingList removeItem(String itemId) {
    final newItems = items.where((item) => item.id != itemId).toList();
    return copyWith(items: newItems);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'tripDate': tripDate?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'description': description,
    };
  }

  factory PackingList.fromJson(Map<String, dynamic> json) {
    return PackingList(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      tripDate: json['tripDate'] != null ? DateTime.parse(json['tripDate']) : null,
      items: (json['items'] as List)
          .map((itemJson) => PackingItem.fromJson(itemJson))
          .toList(),
      description: json['description'],
    );
  }

  @override
  String toString() {
    return 'PackingList(id: $id, name: $name, category: $category, items: ${items.length}, progress: $progress)';
  }
}

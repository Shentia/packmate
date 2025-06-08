import 'package:flutter/foundation.dart';

class PackingItem {
  final String id;
  final String name;
  final bool isPacked;
  final String? category;
  final int? quantity;
  final String? notes;

  PackingItem({
    required this.id,
    required this.name,
    this.isPacked = false,
    this.category,
    this.quantity = 1,
    this.notes,
  });

  PackingItem copyWith({
    String? id,
    String? name,
    bool? isPacked,
    String? category,
    int? quantity,
    String? notes,
  }) {
    return PackingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isPacked: isPacked ?? this.isPacked,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isPacked': isPacked,
      'category': category,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: json['id'],
      name: json['name'],
      isPacked: json['isPacked'] ?? false,
      category: json['category'],
      quantity: json['quantity'] ?? 1,
      notes: json['notes'],
    );
  }

  @override
  String toString() {
    return 'PackingItem(id: $id, name: $name, isPacked: $isPacked, category: $category, quantity: $quantity, notes: $notes)';
  }
}
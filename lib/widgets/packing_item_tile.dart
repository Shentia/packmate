import 'package:flutter/material.dart';
import '../models/packing_item.dart';

class PackingItemTile extends StatelessWidget {
  final PackingItem item;
  final Function(PackingItem) onToggle;
  final Function(String) onDelete;

  const PackingItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: Checkbox(
            value: item.isPacked,
            onChanged: (_) => onToggle(item),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              decoration: item.isPacked ? TextDecoration.lineThrough : null,
              color: item.isPacked ? theme.disabledColor : null,
            ),
          ),
          subtitle: _buildSubtitle(theme),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.quantity != null && item.quantity! > 1)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'x${item.quantity}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onDelete(item.id),
                tooltip: 'Delete item',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildSubtitle(ThemeData theme) {
    if (item.category == null && item.notes == null) {
      return null;
    }

    final List<Widget> subtitleParts = [];
    
    if (item.category != null) {
      subtitleParts.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item.category!,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      );
    }
    
    if (item.notes != null) {
      if (subtitleParts.isNotEmpty) {
        subtitleParts.add(const SizedBox(width: 8));
      }
      
      subtitleParts.add(
        Expanded(
          child: Text(
            item.notes!,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: subtitleParts,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(bool?) onCheckboxChanged;

  const TodoCard({
    Key? key,
    required this.todo,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onCheckboxChanged,
  }) : super(key: key);

  Color _getPriorityColor() {
    switch (todo.priority) {
      case Priority.high:
        return const Color(0xFFFFC9C9); // Pastel Red
      case Priority.medium:
        return const Color(0xFFFFE5B4); // Pastel Orange
      case Priority.low:
        return const Color(0xFFD4EDDA); // Pastel Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : _getPriorityColor().withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: todo.isDone,
                    onChanged: onCheckboxChanged,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: todo.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
              if (todo.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  todo.description,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    decoration: todo.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              DefaultTextStyle(
                style: Theme.of(context).textTheme.bodySmall!,
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(DateFormat('dd MMM yyyy HH:mm').format(todo.createdAt)),
                    if (todo.dueDate != null) ...[
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text('กำหนด: ${DateFormat('dd MMM').format(todo.dueDate!)}'),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

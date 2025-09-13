enum Priority { low, medium, high }

class Todo { 
  final int? id;
  String title;
  String description;
  bool isDone;
  DateTime? dueDate;
  Priority priority;
  String category;
  DateTime createdAt;
 
  Todo({
    this.id,
    required this.title,
    this.description = '',
    this.isDone = false,
    this.dueDate,
    this.priority = Priority.medium,
    this.category = 'default',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
 
  Map<String, dynamic> toMap() { 
    return { 
      'id': id,
      'title': title,
      'description': description,
      'is_done': isDone ? 1 : 0,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority.index,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    }; 
  } 
 
  factory Todo.fromMap(Map<String, dynamic> map) { 
    return Todo( 
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      isDone: (map['is_done'] as int) == 1,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      priority: Priority.values[map['priority'] as int? ?? 1],
      category: map['category'] as String? ?? 'default',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  } 
}
class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  bool isCompleted;
  final String type; // 'inventory', 'invoice', 'expense', 'sale', 'manual'
  final String? relatedItemId;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.type,
    this.relatedItemId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'type': type,
      'related_item_id': relatedItemId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      dueDate: DateTime.parse(map['due_date'] as String),
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      type: map['type'] as String? ?? 'manual',
      relatedItemId: map['related_item_id'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }
}

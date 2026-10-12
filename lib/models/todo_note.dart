import 'package:cloud_firestore/cloud_firestore.dart';

enum TodoPriority { low, medium, high }

class TodoNote {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final TodoPriority priority;
  final String category;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoNote({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = TodoPriority.medium,
    this.category = 'General',
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'category': category,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory TodoNote.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TodoNote.fromMap(doc.id, data);
  }

  factory TodoNote.fromMap(String id, Map<String, dynamic> map) {
    return TodoNote(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      priority: _parsePriority(map['priority']),
      category: map['category'] ?? 'General',
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
    );
  }

  static TodoPriority _parsePriority(dynamic value) {
    if (value == 'high') return TodoPriority.high;
    if (value == 'low') return TodoPriority.low;
    return TodoPriority.medium;
  }

  TodoNote copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TodoPriority? priority,
    String? category,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoNote(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

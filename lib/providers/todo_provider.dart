import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_note.dart';

enum TodoFilter { all, active, completed }

class TodoProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _userId;
  List<TodoNote> _todos = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  // Filters & Search
  TodoFilter _currentFilter = TodoFilter.all;
  TodoPriority? _priorityFilter;
  String _searchQuery = '';

  // Getters
  List<TodoNote> get allTodos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TodoFilter get currentFilter => _currentFilter;
  TodoPriority? get priorityFilter => _priorityFilter;
  String get searchQuery => _searchQuery;

  int get totalCount => _todos.length;
  int get activeCount => _todos.where((t) => !t.isCompleted).length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;

  List<TodoNote> get filteredTodos {
    return _todos.where((todo) {
      // Status filter
      if (_currentFilter == TodoFilter.active && todo.isCompleted) return false;
      if (_currentFilter == TodoFilter.completed && !todo.isCompleted) return false;

      // Priority filter
      if (_priorityFilter != null && todo.priority != _priorityFilter) return false;

      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = todo.title.toLowerCase().contains(query);
        final matchDesc = todo.description.toLowerCase().contains(query);
        final matchCategory = todo.category.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc && !matchCategory) return false;
      }

      return true;
    }).toList();
  }

  // Bind or unbind to current user
  void updateUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();

    if (_userId == null) {
      _todos = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _listenToUserTodos();
  }

  void _listenToUserTodos() {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    final collection = _firestore.collection('users').doc(_userId).collection('todos');

    _subscription = collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _todos = snapshot.docs.map((doc) => TodoNote.fromFirestore(doc)).toList();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (err) {
        _error = 'Error loading tasks: $err';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Filter setters
  void setFilter(TodoFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setPriorityFilter(TodoPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // CRUD Operations
  Future<bool> addTodo({
    required String title,
    String description = '',
    TodoPriority priority = TodoPriority.medium,
    String category = 'General',
    DateTime? dueDate,
  }) async {
    if (_userId == null) return false;

    try {
      final now = DateTime.now();
      final newTodo = TodoNote(
        id: '',
        title: title.trim(),
        description: description.trim(),
        priority: priority,
        category: category,
        dueDate: dueDate,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('todos')
          .add(newTodo.toMap());

      return true;
    } catch (e) {
      _error = 'Failed to add task: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleTodoStatus(String todoId, bool isCompleted) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('todos')
          .doc(todoId)
          .update({
        'isCompleted': isCompleted,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      _error = 'Failed to update status: $e';
      notifyListeners();
    }
  }

  Future<bool> updateTodo({
    required String todoId,
    required String title,
    String description = '',
    required TodoPriority priority,
    required String category,
    DateTime? dueDate,
  }) async {
    if (_userId == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('todos')
          .doc(todoId)
          .update({
        'title': title.trim(),
        'description': description.trim(),
        'priority': priority.name,
        'category': category,
        'dueDate': dueDate?.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      _error = 'Failed to update task: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteTodo(String todoId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('todos')
          .doc(todoId)
          .delete();
    } catch (e) {
      _error = 'Failed to delete task: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

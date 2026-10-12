import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService() {
    // Enable offline persistence settings
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Reference to user's todos subcollection: users/{userId}/todos
  CollectionReference<Map<String, dynamic>> _userTodosRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('todos');
  }

  // Real-time stream of user todos
  Stream<List<Map<String, dynamic>>> streamUserTodos(String userId) {
    return _userTodosRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // Add a new todo / note
  Future<String> addTodo(String userId, Map<String, dynamic> todoData) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final docRef = await _userTodosRef(userId).add({
      ...todoData,
      'createdAt': now,
      'updatedAt': now,
    });
    return docRef.id;
  }

  // Update a todo
  Future<void> updateTodo(
    String userId,
    String todoId,
    Map<String, dynamic> updates,
  ) async {
    await _userTodosRef(userId).doc(todoId).update({
      ...updates,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Toggle todo completion
  Future<void> toggleTodoStatus(
    String userId,
    String todoId,
    bool isCompleted,
  ) async {
    await _userTodosRef(userId).doc(todoId).update({
      'isCompleted': isCompleted,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Delete a todo
  Future<void> deleteTodo(String userId, String todoId) async {
    await _userTodosRef(userId).doc(todoId).delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/todo.dart';

class TodoViewModel with ChangeNotifier {
  List<Todo> _todos = [];
  final String userId;

  List<Todo> get todos => _todos;

  // Firestore 경로: users/{userId}/todos
  CollectionReference<Map<String, dynamic>> get _todosRef =>
      FirebaseFirestore.instance.collection('users').doc(userId).collection('todos');

  // Firestore 경로: users/{userId}/records
  CollectionReference<Map<String, dynamic>> get _recordsRef =>
      FirebaseFirestore.instance.collection('users').doc(userId).collection('records');

  TodoViewModel({required this.userId}) {
    _listenToTodos();
  }

  /// Firestore 실시간 스트림으로 todos 구독
  void _listenToTodos() {
    _todosRef.orderBy('createdAt', descending: false).snapshots().listen(
      (snapshot) {
        _todos = snapshot.docs.map((doc) {
          final data = doc.data();
          return Todo(
            id: doc.id,
            title: data['title'] ?? '',
            status: data['status'] ?? 'TODAY',
            isCompleted: data['isCompleted'] ?? false,
            completedAt: (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime(1970),
          );
        }).toList();
        notifyListeners();
      },
      onError: (e) => debugPrint('Error listening to todos: $e'),
    );
  }

  Future<void> addTodo(Todo todo) async {
    try {
      await _todosRef.doc(todo.id).set({
        'title': todo.title,
        'status': todo.status,
        'isCompleted': todo.isCompleted,
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': null,
      });
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  Future<void> toggleTodo(String id, bool isCompleted) async {
    try {
      await _todosRef.doc(id).update({'isCompleted': isCompleted});
    } catch (e) {
      debugPrint('Error toggling todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _todosRef.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    }
  }

  /// 완료 기록으로 이동 (todos에서 삭제 + records에 추가)
  Future<void> saveRecord(
    String id,
    String title,
    String status,
    bool isCompleted,
  ) async {
    try {
      final now = DateTime.now();
      // records에 저장
      await _recordsRef.add({
        'title': title,
        'status': status,
        'isCompleted': true,
        'completedAt': Timestamp.fromDate(now),
      });
      // todos에서 삭제
      await _todosRef.doc(id).delete();
    } catch (e) {
      debugPrint('Error saving record: $e');
    }
  }

  /// records 스트림 (record_modal에서 사용)
  Stream<List<Map<String, dynamic>>> get recordsStream =>
      _recordsRef.orderBy('completedAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? '',
            'status': data['status'] ?? '',
            'completedAt': (data['completedAt'] as Timestamp?)?.toDate().toIso8601String(),
          };
        }).toList(),
      );
}

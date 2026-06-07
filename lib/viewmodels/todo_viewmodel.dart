import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoViewModel with ChangeNotifier {
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  TodoViewModel() {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getStringList('todos') ?? [];
      _todos = todosJson.map((jsonStr) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return Todo(
          id: map['id'] ?? '',
          title: map['title'] ?? '',
          status: map['status'] ?? 'NOW',
          isCompleted: map['isCompleted'] ?? false,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading todos: $e");
    }
  }

  Future<void> addTodo(Todo todo) async {
    _todos.add(todo);
    notifyListeners();
    await _saveTodos();
  }

  Future<void> toggleTodo(String id, bool isCompleted) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].isCompleted = isCompleted;
      notifyListeners();
      await _saveTodos();
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
    await _saveTodos();
  }

  Future<void> _saveTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _todos.map((todo) => jsonEncode({
        'id': todo.id,
        'title': todo.title,
        'status': todo.status,
        'isCompleted': todo.isCompleted,
      })).toList();
      await prefs.setStringList('todos', list);
    } catch (e) {
      debugPrint("Error saving todos: $e");
    }
  }
}

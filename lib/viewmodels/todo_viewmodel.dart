import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoViewModel with ChangeNotifier {
  List<Todo> _todos = [];
  final List<String> _log = [];

  List<Todo> get todos => _todos;
  List<String> get log => _log;

  TodoViewModel() {
    _loadTodos();
    _loadLog();
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
      debugPrint('Failed to load todos: $e');
    }
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
      debugPrint('Failed to save todos: $e');
    }
  }

  Future<void> _loadLog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logJson = prefs.getStringList('log') ?? [];
      _log = logJson;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load log: $e');
    }
  }

  Future<void> _saveLog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('log', _log);
    } catch (e) {
      debugPrint('Failed to save log: $e');
    }
  }

  void addTodo(Todo todo) async {
    _todos.add(todo);
    notifyListeners();
    await _saveTodos();
    _logAdd(todo);
  }

  void toggleTodo(String id, bool isCompleted) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].isCompleted = isCompleted;
      notifyListeners();
      await _saveTodos();
      _logToggle(id, isCompleted);
    }
  }

  void deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
    await _saveTodos();
    _logDelete(id);
  }

  void _logAdd(Todo todo) {
    _log.add('Added: ${todo.title}');
    _saveLog();
  }

  void _logToggle(String id, bool isCompleted) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _log.add('${isCompleted ? 'Completed' : 'Uncompleted'}: ${_todos[index].title}');
      _saveLog();
    }
  }

  void _logDelete(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _log.add('Deleted: ${_todos[index].title}');
      _saveLog();
    }
  }
}

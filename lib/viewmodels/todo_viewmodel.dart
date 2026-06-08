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
          completedAt: DateTime(
            1970,
          ), // Default value for backward compatibility
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
      final list = _todos
          .map(
            (todo) => jsonEncode({
              'id': todo.id,
              'title': todo.title,
              'status': todo.status,
              'isCompleted': todo.isCompleted,
            }),
          )
          .toList();
      await prefs.setStringList('todos', list);
    } catch (e) {
      debugPrint("Error saving todos: $e");
    }
  }

  Future<void> saveRecord(
    String id,
    String title,
    String status,
    bool isCompleted,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. 기존에 저장되어 있던 완료 기록 리스트를 먼저 읽어옵니다. (없으면 빈 리스트)
      final List<String> existingRecords =
          prefs.getStringList('completedTodos') ?? [];

      // 2. 방금 스와이프해서 넘어온 끈끈한 '새 완료 데이터'를 JSON으로 만듭니다.
      final String newRecord = jsonEncode({
        'id': id,
        'title': title,
        'status': status,
        'isCompleted': true, // 기록으로 넘어왔으니 무조건 true로 저장
        'completedAt': DateTime.now().toIso8601String(), // 완료된 시간 기록
      });

      // 3. 기존 기록 리스트의 '맨 앞(최신순)'에 새 기록을 추가합니다.
      existingRecords.insert(0, newRecord);

      // 4. SharedPreferences에 최종 업데이트된 리스트를 저장합니다.
      await prefs.setStringList('completedTodos', existingRecords);

      // 5. (선택사항) 메인 보드 리스트(_todos)에서도 해당 투두를 지워줍니다.
      _todos.removeWhere((t) => t.id == id);
      notifyListeners(); // UI 새로고침 트리거
    } catch (e) {
      debugPrint("Error saving completed todos: $e");
    }
  }
}

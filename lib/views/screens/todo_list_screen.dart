import 'package:flutter/material.dart';
import 'package:justdoit/models/todo.dart';
import 'package:justdoit/viewmodels/todo_viewmodel.dart';
import 'package:provider/provider.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todoViewModel = Provider.of<TodoViewModel>(context);
    final todos = todoViewModel.todos;

    return Scaffold(
      backgroundColor: Colors.grey[50], // 배경을 살짝 밝은 회색으로 변경하여 카드 부각
      appBar: AppBar(
        title: const Text(
          'All Tasks',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          // 할 일이 없을 때 Empty State 표시
          if (todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '등록된 할 일이 없습니다.\n새로운 태스크를 추가해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            );
          }

          // 정렬 로직 (기존 유지)
          final List<Todo> sortedTodos = List<Todo>.from(todos);
          sortedTodos.sort((a, b) {
            final aDate = a.dueDate ?? DateTime(2100);
            final bDate = b.dueDate ?? DateTime(2100);
            return aDate.compareTo(bDate);
          });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: sortedTodos.length,
            itemBuilder: (context, index) {
              final todo = sortedTodos[index];
              final dateString = todo.dueDate != null
                  ? todo.dueDate!.toIso8601String().split('T').first
                  : 'No date';

              // 밀어서 삭제 기능 추가 (Dismissible)
              return Dismissible(
                key: Key(todo.id.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  // TODO: ViewModel에 deleteTodo가 있다면 연동, 없으면 이 블록 제거 가능
                  // todoViewModel.deleteTodo(todo.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${todo.title}" 삭제되었습니다.')),
                  );
                },
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Opacity(
                  // 완료된 항목은 약간 불투명하게 처리하여 우선순위를 낮춤
                  opacity: todo.isCompleted ? 0.6 : 1.0,
                  child: Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: ListTile(
                        leading: Transform.scale(
                          scale: 1.2, // 체크박스 크기 살짝 확대
                          child: Checkbox(
                            value: todo.isCompleted,
                            activeColor: Colors.deepPurple, // 체크 시 메인 컬러
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4), // 동글동글한 스퀘어 스타일
                            ),
                            onChanged: (value) {
                              todoViewModel.toggleTodo(todo.id, value ?? false);
                            },
                          ),
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: todo.isCompleted ? Colors.grey : Colors.black87,
                            // 완료 시 취소선 효과
                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: todo.isCompleted ? Colors.grey : Colors.deepPurple[300],
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: todo.isCompleted ? Colors.grey[200] : Colors.deepPurple[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  dateString,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: todo.isCompleted ? Colors.grey : Colors.deepPurple[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
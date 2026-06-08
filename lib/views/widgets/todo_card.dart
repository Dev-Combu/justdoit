import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';
import '../../viewmodels/todo_viewmodel.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;

  const TodoCard({required this.todo, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.horizontal,

      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 14.0),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(
            alpha: 0.9,
          ), // 아카이브를 뜻하는 테마 컬러
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Icon(
              Icons.archive_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '기록으로 보내기',
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // ⬅️ 오른쪽에서 왼쪽으로 밀 때: "삭제하기" (기존 유지)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 14.0),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          // 1. 왼쪽으로 밀면 -> 삭제
          todoViewModel.deleteTodo(todo.id);
        } else if (direction == DismissDirection.startToEnd) {
          todoViewModel.saveRecord(
            todo.id,
            todo.title,
            todo.status,
            todo.isCompleted,
          ); // 2. 오른쪽으로 밀면 -> 보관 (아카이브)
        }
      },
      child: Card(
        elevation: todo.isCompleted ? 0 : 2,
        color: todo.isCompleted
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.60)
            : colorScheme.surface.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: todo.isCompleted
                ? Colors.transparent
                : colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        margin: const EdgeInsets.only(bottom: 6.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => todoViewModel.toggleTodo(todo.id, !todo.isCompleted),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: todo.isCompleted
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 14,
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: todo.isCompleted
                          ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                          : colorScheme.onSurface,
                      fontWeight: todo.isCompleted
                          ? FontWeight.normal
                          : FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

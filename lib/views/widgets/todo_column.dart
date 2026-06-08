import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/todo_viewmodel.dart';
import 'todo_card.dart';

class TodoColumn extends StatelessWidget {
  final String status;

  const TodoColumn({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color headerBgColor;
    final Color iconColor;
    final IconData headerIcon;
    switch (status) {
      case 'NOW':
        headerBgColor = Colors.redAccent.withValues(alpha: 0.12);
        iconColor = Colors.redAccent;
        headerIcon = Icons.bolt;
        break;
      case 'TODAY':
        headerBgColor = Colors.blueAccent.withValues(alpha: 0.12);
        iconColor = Colors.blueAccent;
        headerIcon = Icons.today;
        break;
      default:
        headerBgColor = Colors.green.withValues(alpha: 0.12);
        iconColor = Colors.green;
        headerIcon = Icons.calendar_month;
    }

    final todos = context
        .watch<TodoViewModel>()
        .todos
        .where((todo) => todo.status == status)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: headerBgColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(headerIcon, color: iconColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: iconColor,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${todos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: todos.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 24,
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Done!',
                            style: TextStyle(
                              color:
                                  colorScheme.outline.withValues(alpha: 0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 8),
                    itemCount: todos.length,
                    itemBuilder: (context, index) =>
                        TodoCard(todo: todos[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

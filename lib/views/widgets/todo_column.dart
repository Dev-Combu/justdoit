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
      case 'TODAY':
        headerBgColor = Colors.redAccent.withValues(alpha: 0.12);
        iconColor = Colors.redAccent;
        headerIcon = Icons.bolt;
        break;
      case 'WEEK':
        headerBgColor = Colors.blueAccent.withValues(alpha: 0.12);
        iconColor = Colors.blueAccent;
        headerIcon = Icons.today;
        break;
      default:
        headerBgColor = Colors.green.withValues(alpha: 0.12);
        iconColor = Colors.green;
        headerIcon = Icons.calendar_month;
    }

    final now = DateTime.now();
    final todos = context
        .watch<TodoViewModel>()
        .todos
        .where((todo) {
          final due = todo.dueDate;
          if (due == null) return false; // no date -> not shown in columns
          if (status == 'TODAY') {
            return due.year == now.year && due.month == now.month && due.day == now.day;
          }
          if (status == 'WEEK') {
            // week starts Monday
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            final weekEnd = weekStart.add(Duration(days: 6));
            return due.isAfter(weekStart.subtract(Duration(seconds: 1))) &&
                due.isBefore(weekEnd.add(Duration(days: 1))) &&
                !(due.year == now.year && due.month == now.month && due.day == now.day);
          }
          if (status == 'MONTH') {
            // within current month but not this week
            final monthStart = DateTime(now.year, now.month, 1);
            final monthEnd = DateTime(now.year, now.month + 1, 0);
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            final weekEnd = weekStart.add(Duration(days: 6));
            final inMonth = due.isAfter(monthStart.subtract(Duration(seconds: 1))) &&
                due.isBefore(monthEnd.add(Duration(days: 1)));
            final inWeek = due.isAfter(weekStart.subtract(Duration(seconds: 1))) &&
                due.isBefore(weekEnd.add(Duration(days: 1)));
            return inMonth && !inWeek;
          }
          return false;
        })
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

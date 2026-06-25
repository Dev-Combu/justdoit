import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';
import '../../viewmodels/todo_viewmodel.dart';

class AddTodoModal extends StatefulWidget {
  const AddTodoModal({super.key});

  /// Shows the add-todo bottom sheet and returns once dismissed.
  static void show(BuildContext context) {
    final todoVM = Provider.of<TodoViewModel>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: todoVM,
        child: const AddTodoModal(),
      ),
    );
  }

  @override
  State<AddTodoModal> createState() => _AddTodoModalState();
}

class _AddTodoModalState extends State<AddTodoModal> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;


  // Determine status based on a given date
  String _determineStatus(DateTime date) {
    final now = DateTime.now();
    // Today
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'TODAY';
    }
    // Week: compare ISO week numbers
    int weekNumber(DateTime d) {
      final firstDayOfYear = DateTime(d.year, 1, 1);
      final daysOffset = firstDayOfYear.weekday % 7;
      final firstMonday = firstDayOfYear.add(Duration(days: daysOffset == 0 ? 0 : 7 - daysOffset));
      return ((d.difference(firstMonday).inDays) / 7).floor() + 1;
    }

    if (weekNumber(date) == weekNumber(now)) {
      return 'WEEK';
    }
    // Otherwise treat as month
    return 'MONTH';
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

    void _submit() {
      final text = _titleController.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a task title.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      // Determine status automatically if not selected
      final status = _selectedDate != null ? _determineStatus(_selectedDate!) : 'TODAY';
      Provider.of<TodoViewModel>(context, listen: false).addTodo(
        Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: text,
          status: status,
          completedAt: DateTime(1970),
          dueDate: _selectedDate,
        ),
      );
      Navigator.pop(context);
    }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'New Task',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'What needs to be done?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Priority / Timeline',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            // Date picker UI
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No date selected'
                        : 'Due: <${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}>',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Select Date'),
                ),
              ],
            ),
            const SizedBox(height: 24),


            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add),
              label: const Text('Create Task'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

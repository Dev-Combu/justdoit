import 'package:flutter/material.dart';
import 'package:justdoit/viewmodels/todo_viewmodel.dart';
import 'package:justdoit/viewmodels/window_viewmodel.dart';
import 'package:justdoit/views/widgets/add_todo_modal.dart';
import 'package:justdoit/views/widgets/todo_column.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final windowVM = context.watch<WindowViewModel>();
    final isLocked = windowVM.isLocked;
    final colorScheme = Theme.of(context).colorScheme;
    final todoVM = Provider.of<TodoViewModel>(context, listen: false);

    final dragHandle = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      color: Colors.transparent,
      child: Center(
        child: Text(
          'Drag to resize',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Just Do It'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              AddTodoModal.show(context);
            },
          ),
          IconButton(
            icon: Icon(isLocked ? Icons.lock : Icons.lock_open),
            onPressed: () async {
              await todoVM.toggleLock();
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              // Show log
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Log'),
                    content: ListView.builder(
                      itemCount: todoVM.log.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(todoVM.log[index]),
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          dragHandle,
          Expanded(
            child: TodoColumn(status: 'NOW'),
          ),
          Expanded(
            child: TodoColumn(status: 'LATER'),
          ),
        ],
      ),
    );
  }
}

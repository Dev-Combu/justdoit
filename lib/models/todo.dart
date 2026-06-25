class Todo {
  final String id;
  final String title;
  final String status;
  bool isCompleted;
  final DateTime completedAt;
  DateTime? dueDate;

  Todo({
    required this.id,
    required this.title,
    required this.status,
    required this.completedAt,
    this.isCompleted = false,
    this.dueDate,
  });
}

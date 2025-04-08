class Task {
  String id;
  String title;
  bool completed;
  String priority;
  String timeBlock;
  List<String> subtasks;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    this.priority = 'Medium',
    this.timeBlock = '',
    this.subtasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'completed': completed,
      'priority': priority,
      'timeBlock': timeBlock,
      'subtasks': subtasks,
    };
  }

  static Task fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'],
      completed: map['completed'],
      priority: map['priority'],
      timeBlock: map['timeBlock'],
      subtasks: List<String>.from(map['subtasks']),
    );
  }
}

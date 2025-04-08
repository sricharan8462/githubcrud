class Task {
  String id;
  String name;
  bool isCompleted;
  List<SubTask> subTasks;

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.subTasks = const [],
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'isCompleted': isCompleted,
        'subTasks': subTasks.map((sub) => sub.toMap()).toList(),
      };

  factory Task.fromMap(String id, Map<String, dynamic> map) => Task(
        id: id,
        name: map['name'],
        isCompleted: map['isCompleted'],
        subTasks: (map['subTasks'] as List).map((sub) => SubTask.fromMap(sub)).toList(),
      );
}

class SubTask {
  String timeFrame;
  String details;

  SubTask({required this.timeFrame, required this.details});

  Map<String, dynamic> toMap() => {'timeFrame': timeFrame, 'details': details};

  factory SubTask.fromMap(Map<String, dynamic> map) => SubTask(
        timeFrame: map['timeFrame'],
        details: map['details'],
      );
}
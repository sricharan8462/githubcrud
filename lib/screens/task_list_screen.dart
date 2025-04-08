import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import 'login_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final taskController = TextEditingController();
  final subtaskController = TextEditingController();
  final timeBlockController = TextEditingController();
  String priority = 'Medium';

  final uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void addTask() {
    firestore.collection('users').doc(uid).collection('tasks').add({
      'title': taskController.text,
      'completed': false,
      'priority': priority,
      'timeBlock': timeBlockController.text,
      'subtasks': subtaskController.text.isNotEmpty
          ? subtaskController.text.split(',')
          : [],
    });
    taskController.clear();
    subtaskController.clear();
    timeBlockController.clear();
  }

  void updateTask(Task task, bool? value) {
    firestore.collection('users').doc(uid).collection('tasks').doc(task.id).update({'completed': value});
  }

  void deleteTask(String taskId) {
    firestore.collection('users').doc(uid).collection('tasks').doc(taskId).delete();
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final tasksRef = firestore.collection('users').doc(uid).collection('tasks');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Task List"),
        actions: [IconButton(onPressed: logout, icon: const Icon(Icons.logout))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(controller: taskController, decoration: const InputDecoration(labelText: 'Task Title')),
                TextField(controller: timeBlockController, decoration: const InputDecoration(labelText: 'Time Block (e.g. Monday 9-10 AM)')),
                TextField(controller: subtaskController, decoration: const InputDecoration(labelText: 'Subtasks (comma separated)')),
                DropdownButton<String>(
                  value: priority,
                  items: ['High', 'Medium', 'Low'].map((level) =>
                      DropdownMenuItem(value: level, child: Text(level))).toList(),
                  onChanged: (val) => setState(() => priority = val!),
                ),
                ElevatedButton(onPressed: addTask, child: const Text('Add Task')),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasksRef.orderBy('priority').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final tasks = snapshot.data!.docs.map((doc) =>
                    Task.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, i) {
                    final task = tasks[i];
                    return Card(
                      child: ListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                            color: task.priority == 'High' ? Colors.red :
                                   task.priority == 'Medium' ? Colors.orange : Colors.green,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Priority: ${task.priority}"),
                            Text("Time: ${task.timeBlock}"),
                            if (task.subtasks.isNotEmpty)
                              ...task.subtasks.map((st) => Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text("- $st", style: const TextStyle(fontSize: 12)),
                              )),
                          ],
                        ),
                        trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteTask(task.id)),
                        leading: Checkbox(
                          value: task.completed,
                          onChanged: (val) => updateTask(task, val),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

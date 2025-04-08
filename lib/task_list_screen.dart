import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task.dart';
import 'login_screen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _taskController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void _addTask() async {
    if (_taskController.text.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('tasks')
          .add(Task(
            id: '', // ID will be set by Firestore
            name: _taskController.text,
            subTasks: [
              SubTask(timeFrame: '9 AM - 10 AM', details: 'HW1, Essay2'),
              SubTask(timeFrame: '12 PM - 2 PM', details: 'Meeting, Review'),
            ],
          ).toMap());
      _taskController.clear();
    }
  }

  void _toggleTask(String id, bool currentStatus) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(id)
        .update({'isCompleted': !currentStatus});
  }

  void _deleteTask(String id) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(id)
        .delete();
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [IconButton(onPressed: _logout, icon: Icon(Icons.logout))],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(labelText: 'Task Name'),
                  ),
                ),
                ElevatedButton(onPressed: _addTask, child: Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(_auth.currentUser!.uid)
                  .collection('tasks')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final tasks = snapshot.data!.docs
                    .map((doc) => Task.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                    .toList();
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ExpansionTile(
                      title: Row(
                        children: [
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) => _toggleTask(task.id, task.isCompleted),
                          ),
                          Expanded(child: Text(task.name)),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteTask(task.id),
                          ),
                        ],
                      ),
                      children: task.subTasks
                          .map((sub) => ListTile(
                                title: Text(sub.timeFrame),
                                subtitle: Text(sub.details),
                              ))
                          .toList(),
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
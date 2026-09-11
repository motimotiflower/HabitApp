//タスクを表示するページ
import 'package:flutter/material.dart';
import 'package:habitapp/models/task.dart';
import 'package:habitapp/z_task/widgets/task_card.dart';
import 'package:habitapp/main/widgets/main_content.dart';
import 'package:habitapp/z_task/task_storage.dart';
import 'package:habitapp/z_task/sheets/edit_task_sheet.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  List<Task> tasks = [];

  //データの追加
  void addTask(Task task) {
    setState(() {
      tasks.add(task);
    });

    TaskStorage.saveTasks(tasks);
  }

  //データの編集
  void editTask(Task oldTask, Task newTask) {
    final index = tasks.indexOf(oldTask);
    if (index == -1) return;

    setState(() {
      tasks[index] = newTask;
    });

    TaskStorage.saveTasks(tasks);
  }

  //データの削除
  void deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });

    TaskStorage.saveTasks(tasks);
  }

  //編集画面
  void showEditSheet(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.80,
          child: EditTaskSheet(
            task: task,
            onSave: (editedTask) {
              editTask(task, editedTask);
            },
          ),
        );
      },
    );
  }

  //削除確認ダイアログ
  void showDeleteDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('タスクを削除'),
          content: Text('「${task.title}」を削除しますか？'),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xffE88796),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        deleteTask(task);
                      },
                      child: const Text('削除'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('キャンセル'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await TaskStorage.loadTasks();

    if (!mounted) return;

    setState(() {
      tasks = loadedTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    //表示専用のコピー
    final sortedTasks = [...tasks];

    //未完了 → 締切が近い順 → 重要度が高い順
    sortedTasks.sort((a, b) {
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }

      if (a.deadline != null && b.deadline != null) {
        final deadlineCompare = a.deadline!.compareTo(b.deadline!);
        if (deadlineCompare != 0) return deadlineCompare;
      }

      if (a.deadline == null && b.deadline != null) return 1;
      if (a.deadline != null && b.deadline == null) return -1;

      return b.priority.compareTo(a.priority);
    });

    return MainContent(
      overlap: 10,
      child: tasks.isEmpty
          ? const Center(
              child: Text(
                'タスクはまだありません',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: sortedTasks.length,
              itemBuilder: (context, index) {
                final task = sortedTasks[index];

                return TaskCard(
                  task: task,

                  onChanged: () {
                    setState(() {
                      task.isDone = !task.isDone;
                    });

                    TaskStorage.saveTasks(tasks);
                  },

                  onEdit: () {
                    showEditSheet(task);
                  },

                  onDelete: () {
                    showDeleteDialog(task);
                  },
                );
              },
            ),
    );
  }
}

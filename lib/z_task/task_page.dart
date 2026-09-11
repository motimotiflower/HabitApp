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

  //表示フィルター
  String _selectedFilter = 'すべて';

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

  //フィルターを反映した一覧を作る
  List<Task> _getVisibleTasks() {
    final visibleTasks = tasks.where((task) {
      if (_selectedFilter == '未完了') {
        return !task.isDone;
      }

      if (_selectedFilter == '完了') {
        return task.isDone;
      }

      return true;
    }).toList();

    //未完了 → 締切が近い順 → 重要度が高い順
    visibleTasks.sort((a, b) {
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

    return visibleTasks;
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = _getVisibleTasks();

    final incompleteCount = tasks.where((task) => !task.isDone).length;
    final completedCount = tasks.where((task) => task.isDone).length;

    return MainContent(
      overlap: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //件数表示
          Row(
            children: [
              const Text(
                'タスク',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '未完了 $incompleteCount  /  完了 $completedCount',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xff7C7690),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          //表示切り替え
          Wrap(
            spacing: 8,
            children: ['すべて', '未完了', '完了'].map((filter) {
              return ChoiceChip(
                label: Text(filter),
                selected: _selectedFilter == filter,
                selectedColor: const Color(0xffE8E3FA),
                labelStyle: TextStyle(
                  color: _selectedFilter == filter
                      ? const Color(0xff6658A8)
                      : const Color(0xff6F6A7C),
                  fontWeight: _selectedFilter == filter
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                onSelected: (_) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: visibleTasks.isEmpty
                ? Center(
                    child: Text(
                      tasks.isEmpty
                          ? 'タスクはまだありません'
                          : 'この条件のタスクはありません',
                      style: const TextStyle(
                        color: Color(0xff8D8799),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: visibleTasks.length,
                    itemBuilder: (context, index) {
                      final task = visibleTasks[index];

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
          ),
        ],
      ),
    );
  }
}

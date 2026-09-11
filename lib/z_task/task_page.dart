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

  //表示条件
  String _selectedStatus = 'すべて';
  String _selectedCategory = 'すべて';

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

      //編集でジャンルがなくなった場合は絞り込みを戻す
      final categories = _getCategories();
      if (_selectedCategory != 'すべて' &&
          !categories.contains(_selectedCategory)) {
        _selectedCategory = 'すべて';
      }
    });

    TaskStorage.saveTasks(tasks);
  }

  //データの削除
  void deleteTask(Task task) {
    setState(() {
      tasks.remove(task);

      final categories = _getCategories();
      if (_selectedCategory != 'すべて' &&
          !categories.contains(_selectedCategory)) {
        _selectedCategory = 'すべて';
      }
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
                        backgroundColor: const Color(0xff526FC5),
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
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff526FC5),
                      ),
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

  //現在使われているジャンル一覧
  List<String> _getCategories() {
    final categories = tasks
        .map((task) => task.category.trim())
        .where((category) => category.isNotEmpty && category != '未設定')
        .toSet()
        .toList();

    categories.sort();

    return categories;
  }

  //絞り込みと並び替え
  List<Task> _getVisibleTasks() {
    final visibleTasks = tasks.where((task) {
      final statusMatches =
          _selectedStatus == 'すべて' ||
          (_selectedStatus == '未完了' && !task.isDone) ||
          (_selectedStatus == '完了' && task.isDone);

      final categoryMatches =
          _selectedCategory == 'すべて' ||
          task.category == _selectedCategory;

      return statusMatches && categoryMatches;
    }).toList();

    //未完了を先にして、締切が近い順
    visibleTasks.sort((a, b) {
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }

      if (a.deadline != null && b.deadline != null) {
        return a.deadline!.compareTo(b.deadline!);
      }

      if (a.deadline == null && b.deadline != null) return 1;
      if (a.deadline != null && b.deadline == null) return -1;

      return 0;
    });

    return visibleTasks;
  }

  //青いヘッダー上の絞り込みUI
  Widget _buildHeaderFilters(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final categories = _getCategories();

    return Positioned(
      top: screenHeight * 0.15,
      left: 20,
      right: 20,
      child: Column(
        children: [
          //完了状態
          Row(
            children: ['すべて', '未完了', '完了'].map((status) {
              final selected = _selectedStatus == status;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    child: Container(
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: selected
                              ? const Color(0xff36559F)
                              : Colors.white,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 9),

          //ジャンル
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: const Color(0xff36559F),
                iconEnabledColor: Colors.white,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'すべて',
                    child: Text('すべてのジャンル'),
                  ),
                  ...categories.map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = _getVisibleTasks();

    return Stack(
      children: [
        //青い背景部分に表示
        _buildHeaderFilters(context),

        //白いカード部分
        MainContent(
          overlap: 10,
          child: visibleTasks.isEmpty
              ? Center(
                  child: Text(
                    tasks.isEmpty
                        ? 'タスクはまだありません'
                        : 'この条件のタスクはありません',
                    style: const TextStyle(
                      color: Color(0xff81889B),
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
    );
  }
}

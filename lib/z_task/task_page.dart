//タスクを表示するページ
import 'package:flutter/material.dart';
import 'package:habitapp/models/task.dart';
import 'package:habitapp/z_task/widgets/task_card.dart';
import 'package:habitapp/main/widgets/main_content.dart';
import 'package:habitapp/main/widgets/main_background.dart';
import 'package:habitapp/main/widgets/adaptive_editor_panel.dart';
import 'package:habitapp/z_task/task_storage.dart';
import 'package:habitapp/z_task/category_storage.dart';
import 'package:habitapp/z_task/sheets/edit_task_sheet.dart';
import 'package:habitapp/z_task/sheets/category_manage_sheet.dart';
import 'package:habitapp/z_star/star_storage.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  List<Task> tasks = [];
  List<String> _categories = [];

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

  //ジャンル追加
  Future<void> _addCategory(String category) async {
    if (_categories.contains(category)) return;

    setState(() {
      _categories.add(category);
      _categories.sort();
    });

    await CategoryStorage.saveCategories(_categories);
  }

  //ジャンル名変更
  Future<void> _renameCategory(String oldName, String newName) async {
    setState(() {
      final categoryIndex = _categories.indexOf(oldName);
      if (categoryIndex != -1) {
        _categories[categoryIndex] = newName;
        _categories.sort();
      }

      //既存タスクのジャンル名も変更
      tasks = tasks.map((task) {
        if (task.category != oldName) return task;

        return Task(
          id: task.id,
          title: task.title,
          description: task.description,
          deadline: task.deadline,
          category: newName,
          isFlagged: task.isFlagged,
          notificationEnabled: task.notificationEnabled,
          notificationDays: task.notificationDays,
          notificationDate: task.notificationDate,
          notificationHour: task.notificationHour,
          notificationMinute: task.notificationMinute,
          isDone: task.isDone,
        );
      }).toList();

      if (_selectedCategory == oldName) {
        _selectedCategory = newName;
      }
    });

    await CategoryStorage.saveCategories(_categories);
    await TaskStorage.saveTasks(tasks);
  }

  //ジャンル削除
  Future<void> _deleteCategory(String category) async {
    setState(() {
      _categories.remove(category);

      //削除したジャンルのタスクは未設定に戻す
      tasks = tasks.map((task) {
        if (task.category != category) return task;

        return Task(
          id: task.id,
          title: task.title,
          description: task.description,
          deadline: task.deadline,
          category: '未設定',
          isFlagged: task.isFlagged,
          notificationEnabled: task.notificationEnabled,
          notificationDays: task.notificationDays,
          notificationDate: task.notificationDate,
          notificationHour: task.notificationHour,
          notificationMinute: task.notificationMinute,
          isDone: task.isDone,
        );
      }).toList();

      if (_selectedCategory == category) {
        _selectedCategory = 'すべて';
      }
    });

    await CategoryStorage.saveCategories(_categories);
    await TaskStorage.saveTasks(tasks);
  }

  //編集画面
  void showEditSheet(Task task) {
    showAdaptiveEditor(
      context: context,
      mobileHeightFactor: 0.80,
      builder: (context) {
        return EditTaskSheet(
          task: task,
          onSave: (editedTask) {
            editTask(task, editedTask);
          },
        );
      },
    );
  }

  //ジャンル管理画面
  Future<void> _showCategoryManageSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
        //大画面でも追加・編集画面を横幅いっぱいに広げる
        constraints: const BoxConstraints(maxWidth: double.infinity),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.78,
          child: CategoryManageSheet(
            categories: _categories,
            onAdd: _addCategory,
            onRename: _renameCategory,
            onDelete: _deleteCategory,
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
    _loadData();
  }

  //他ページから戻った時に保存データと同期
  Future<void> reloadTasks() async {
    await _loadData();
  }

  //タスクとジャンルを読み込む
  Future<void> _loadData() async {
    final loadedTasks = await TaskStorage.loadTasks();
    final loadedCategories = await CategoryStorage.loadCategories();

    //以前作ったタスクのジャンルもジャンル一覧へ引き継ぐ
    final taskCategories = loadedTasks
        .map((task) => task.category.trim())
        .where((category) => category.isNotEmpty && category != '未設定');

    final mergedCategories = {
      ...loadedCategories,
      ...taskCategories,
    }.toList()
      ..sort();

    if (mergedCategories.length != loadedCategories.length) {
      await CategoryStorage.saveCategories(mergedCategories);
    }

    if (!mounted) return;

    setState(() {
      tasks = loadedTasks;
      _categories = mergedCategories;
    });
  }

  //絞り込みと並び替え
  List<Task> _getVisibleTasks() {
    final visibleTasks = tasks.where((task) {
      final statusMatches =
          (_selectedStatus == 'すべて' && !task.isDone) ||
          (_selectedStatus == '期限あり' &&
              !task.isDone &&
              task.deadline != null) ||
          (_selectedStatus == '完了' && task.isDone);

      final categoryMatches =
          _selectedCategory == 'すべて' ||
          task.category == _selectedCategory;

      return statusMatches && categoryMatches;
    }).toList();

    //締切があるものは近い順、締切なしは後ろ
    visibleTasks.sort((a, b) {
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

    return Positioned(
      top: screenHeight * MainBackground.headerRatio * 0.56,
      left: 20,
      right: 20,
      child: Column(
        children: [
          //表示タブ
          Row(
            children: ['すべて', '期限あり', '完了'].map((status) {
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

          //ジャンル絞り込み・管理
          Row(
            children: [
              Expanded(
                child: Container(
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
                        ..._categories.map(
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
              ),

              const SizedBox(width: 8),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onPressed: _showCategoryManageSheet,
                icon: const Icon(Icons.folder_outlined, size: 17),
                label: const Text(
                  'ジャンル管理',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
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
          overlap: 0,
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
                  //右下の＋ボタンと最後のチェックが重ならないよう下に余白
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: visibleTasks.length,
                  itemBuilder: (context, index) {
                    final task = visibleTasks[index];

                    return TaskCard(
                      task: task,
                      onChanged: () async {
                        final wasDone = task.isDone;

                        setState(() {
                          task.isDone = !wasDone;
                        });

                        await TaskStorage.saveTasks(tasks);

                        //完了で星の欠片+1、ガチャ前なら解除で取り消す
                        final actionKey = 'task|${task.id}';

                        if (!wasDone) {
                          await StarStorage.award(
                            actionKey: actionKey,
                            source: 'task',
                          );
                        } else {
                          await StarStorage.revoke(actionKey);
                        }
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

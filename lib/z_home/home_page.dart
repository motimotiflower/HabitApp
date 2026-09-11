//ホーム画面
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_content.dart';
import 'package:habitapp/models/task.dart';
import 'package:habitapp/z_task/task_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Task> _todayTasks = [];

  @override
  void initState() {
    super.initState();
    reload();
  }

  //保存データから今日締切のタスクを読み込む
  Future<void> reload() async {
    final tasks = await TaskStorage.loadTasks();
    final now = DateTime.now();

    final todayTasks = tasks.where((task) {
      final deadline = task.deadline;

      if (deadline == null || task.isDone) {
        return false;
      }

      return deadline.year == now.year &&
          deadline.month == now.month &&
          deadline.day == now.day;
    }).toList();

    if (!mounted) return;

    setState(() {
      _todayTasks = todayTasks;
    });
  }

  //ホームから完了にする
  Future<void> _completeTask(Task targetTask) async {
    final tasks = await TaskStorage.loadTasks();

    for (final task in tasks) {
      if (task.title == targetTask.title &&
          task.deadline == targetTask.deadline &&
          task.category == targetTask.category &&
          !task.isDone) {
        task.isDone = true;
        break;
      }
    }

    await TaskStorage.saveTasks(tasks);
    await reload();
  }

  @override
  Widget build(BuildContext context) {
    return MainContent(
      overlap: 10,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const Text(
            '今日のタスク',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff35415F),
            ),
          ),

          const SizedBox(height: 12),

          if (_todayTasks.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffF2F4FC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xffCDD5F0),
                ),
              ),
              child: const Center(
                child: Text(
                  '今日締切のタスクはありません',
                  style: TextStyle(
                    color: Color(0xff81889B),
                  ),
                ),
              ),
            )
          else
            ..._todayTasks.map(
              (task) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF2F4FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xffCDD5F0),
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: false,
                      activeColor: const Color(0xff526FC5),
                      onChanged: (_) {
                        _completeTask(task);
                      },
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xff35415F),
                            ),
                          ),

                          if (task.category != '未設定') ...[
                            const SizedBox(height: 3),
                            Text(
                              task.category,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xff526FC5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Text(
                      '今日まで',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff526FC5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          //今後、習慣やメモもここに追加できる
          const Text(
            '今日の習慣',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff35415F),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            decoration: BoxDecoration(
              color: const Color(0xffF2F4FC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xffCDD5F0),
              ),
            ),
            child: const Center(
              child: Text(
                '習慣のホーム連携は次に追加',
                style: TextStyle(
                  color: Color(0xff81889B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//タスクを表示するページ
import 'package:flutter/material.dart';
import 'package:habitapp/models/task.dart';
import 'package:habitapp/z_task/widgets/task_card.dart';
import 'package:habitapp/main/widgets/main_content.dart';
import 'package:habitapp/z_task/task_storage.dart';

//タスク画面を表すWidget======================================
class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => TaskPageState();
}

//TaskPageの値や見た目の管理=================================
class TaskPageState extends State<TaskPage> {
  //変数=====================================

  //タスク一覧
  List<Task> tasks = [];

  //データの追加=================================
  void addTask(Task task) {
    setState(() {
      tasks.add(task);
    });

    //追加後のタスク一覧を保存
    TaskStorage.saveTasks(tasks);
  }

  //データの削除=================================
  void deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });

    //削除後のタスク一覧を保存
    TaskStorage.saveTasks(tasks);
  }

  //削除確認ダイアログ=========================
  void showDeleteDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('タスクを削除'),
          content: Text('「${task.title}」を削除しますか？'),

          actions: [
            //ボタンを縦に並べる
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  //削除
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        //ダイアログを閉じる
                        Navigator.pop(context);

                        //タスクを削除
                        deleteTask(task);
                      },
                      child: const Text(
                        '削除',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),

                  //キャンセル
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        //ダイアログだけ閉じる
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

  //保存データの読み込み===========================
  @override
  void initState() {
    super.initState();

    //TaskPageが最初に作られた時に保存データを読み込む
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    //保存されているタスク一覧を取得
    final loadedTasks = await TaskStorage.loadTasks();

    //読み込み中にWidgetが破棄されていたら終了
    if (!mounted) return;

    setState(() {
      tasks = loadedTasks;
    });
  }

  //画面を作る処理===========================
  @override
  Widget build(BuildContext context) {
    //表示用のコピーしたタスク一覧
    final sortedTasks = [...tasks];

    //未完了を先にして、締切が近い順に並べる
    sortedTasks.sort((a, b) {
      //完了状態が違う場合は未完了を先にする
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }

      //両方とも締切なし
      if (a.deadline == null && b.deadline == null) {
        return 0;
      }

      //aだけ締切なし
      if (a.deadline == null) {
        return 1;
      }

      //bだけ締切なし
      if (b.deadline == null) {
        return -1;
      }

      //締切が近い方を先にする
      return a.deadline!.compareTo(b.deadline!);
    });

    return MainContent(
      overlap: 10,

      //タスク一覧
      child: ListView.builder(
        padding: EdgeInsets.zero,

        //表示するタスクの数
        itemCount: tasks.length,

        //タスク1件分を表示
        itemBuilder: (context, index) {
          final task = tasks[index];

          return TaskCard(
            task: task,

            //チェックボタンが押された時
            onChanged: () {
              setState(() {
                task.isDone = !task.isDone;
              });

              //変更後の完了状態を保存
              TaskStorage.saveTasks(tasks);
            },

            //削除ボタンが押された時
            onDelete: () {
              showDeleteDialog(task);
            },
          );
        },
      ),
    );
  }
}

//タスク追加画面
import 'package:flutter/material.dart';
import 'package:habitapp/models/task.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key, required this.onAddTask});

  //追加したタスクをMainPage側へ渡す
  final void Function(Task task) onAddTask;

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  //変数=====================================

  //タスク名入力用
  final TextEditingController _titleController = TextEditingController();

  //選択した締切日
  DateTime? _deadline;

  //日付選択=================================
  Future<void> _selectDeadline() async {
    final selectedDate = await showDatePicker(
      context: context,

      //最初に表示する日
      initialDate: DateTime.now(),

      //選択できる最初の日
      firstDate: DateTime.now(),

      //選択できる最後の日
      lastDate: DateTime(2030),
    );

    //キャンセルされた場合は何もしない
    if (selectedDate == null) return;

    setState(() {
      _deadline = selectedDate;
    });
  }

  //タスク追加===============================
  void _addTask() {
    final title = _titleController.text.trim();

    //タスク名が空なら追加しない
    if (title.isEmpty) return;

    final newTask = Task(title: title, deadline: _deadline);

    //MainPage側へタスクを渡す
    widget.onAddTask(newTask);

    //追加画面を閉じる
    Navigator.pop(context);
  }

  //========================================
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,

        //キーボード分だけ下に余白を追加
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //タイトル
          const Text(
            'タスクを追加',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          //タスク名
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'タスク名',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          //締切日
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(
              _deadline == null
                  ? '締切日を選択'
                  : '${_deadline!.year}年${_deadline!.month}月${_deadline!.day}日',
            ),
            onTap: _selectDeadline,
          ),

          const Spacer(),

          //追加ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _addTask, child: const Text('追加')),
          ),
        ],
      ),
    );
  }

  //Controllerの後片付け=====================
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

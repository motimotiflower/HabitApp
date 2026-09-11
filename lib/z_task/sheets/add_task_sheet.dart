//タスク追加画面
import 'package:flutter/material.dart';
import 'package:habitapp/models/task.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key, required this.onAddTask});

  final void Function(Task task) onAddTask;

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  DateTime? _deadline;

  //締切日を選ぶ
  Future<void> _selectDeadline() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (selectedDate == null) return;

    setState(() {
      _deadline = selectedDate;
    });
  }

  //タスクを追加する
  void _addTask() {
    final title = _titleController.text.trim();
    final category = _categoryController.text.trim();

    if (title.isEmpty) return;

    widget.onAddTask(
      Task(
        title: title,
        deadline: _deadline,
        category: category.isEmpty ? '未設定' : category,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'タスクを追加',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Color(0xff526FC5),
                      ),
                      title: Text(
                        _deadline == null
                            ? '締切日を選択'
                            : '${_deadline!.year}年${_deadline!.month}月${_deadline!.day}日',
                      ),
                      trailing: _deadline == null
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _deadline = null;
                                });
                              },
                            ),
                      onTap: _selectDeadline,
                    ),

                    const SizedBox(height: 12),

                    //ジャンルは自由に作成できる
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'ジャンル',
                        hintText: '例：勉強、買い物、サークル',
                        prefixIcon: Icon(
                          Icons.folder_outlined,
                          color: Color(0xff526FC5),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff526FC5),
                  foregroundColor: Colors.white,
                ),
                onPressed: _addTask,
                child: const Text('追加'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}

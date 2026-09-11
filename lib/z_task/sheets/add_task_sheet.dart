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

  DateTime? _deadline;
  String _category = '未設定';
  int _priority = 0;

  static const List<String> _categories = [
    '未設定',
    '勉強',
    '仕事',
    '生活',
    '健康',
    'サークル',
    'その他',
  ];

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
    if (title.isEmpty) return;

    widget.onAddTask(
      Task(
        title: title,
        deadline: _deadline,
        category: _category,
        priority: _priority,
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
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'タスク名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
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

                    const Text(
                      'ジャンル',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        return ChoiceChip(
                          label: Text(category),
                          selected: _category == category,
                          onSelected: (_) {
                            setState(() {
                              _category = category;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      '重要度',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _priorityChip('なし', 0),
                        _priorityChip('低', 1),
                        _priorityChip('中', 2),
                        _priorityChip('高', 3),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addTask,
                child: const Text('追加'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //重要度選択を共通化
  Widget _priorityChip(String label, int value) {
    return ChoiceChip(
      label: Text(label),
      selected: _priority == value,
      onSelected: (_) {
        setState(() {
          _priority = value;
        });
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
